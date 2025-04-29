# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasComponent
      include Decidim::HasReference
      include Decidim::ScopableResource
      include Decidim::HasCategory
      include Decidim::Taxonomizable
      include Decidim::Followable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Comments::HasAvailabilityAttributes
      include Decidim::Searchable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::DownloadYourData
      include Decidim::Forms::HasQuestionnaire
      include Decidim::Paddable
      include Decidim::ActsAsAuthor
      include Decidim::Reportable
      include Decidim::Authorable
      include Decidim::TranslatableResource
      include Decidim::Publicable
      include Decidim::FilterableResource
      include Decidim::SoftDeletable

      TYPE_OF_MEETING = { in_person: 0, online: 10, hybrid: 20 }.freeze
      REGISTRATION_TYPES = { registration_disabled: 0, on_this_platform: 10, on_different_platform: 20 }.freeze

      translatable_fields :title, :description, :location, :location_hints, :closing_report, :registration_terms

      has_many :registrations, class_name: "Decidim::Meetings::Registration", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_many :invites, class_name: "Decidim::Meetings::Invite", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_many :services, class_name: "Decidim::Meetings::Service", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_one :agenda, class_name: "Decidim::Meetings::Agenda", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_one :poll, class_name: "Decidim::Meetings::Poll", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_many(
        :public_participants,
        -> { merge(Registration.public_participant) },
        through: :registrations,
        class_name: "Decidim::User",
        foreign_key: :decidim_user_id,
        source: :user
      )
      has_many :meeting_links, dependent: :destroy, class_name: "Decidim::Meetings::MeetingLink", foreign_key: "decidim_meeting_id"
      has_many :components, through: :meeting_links, class_name: "Decidim::Component", foreign_key: "decidim_component_id"

      enum iframe_access_level: [:all, :signed_in, :registered], _prefix: true
      enum iframe_embed_type: [:none, :embed_in_meeting_page, :open_in_live_event_page, :open_in_new_tab], _prefix: true
      enum type_of_meeting: TYPE_OF_MEETING
      enum registration_type: REGISTRATION_TYPES, _scopes: false

      component_manifest_name "meetings"

      validates :title, presence: true

      geocoded_by :address

      scope :closed, -> { where.not(closed_at: nil) }
      scope :published, -> { where.not(published_at: nil) }
      scope :past, -> { where(arel_table[:end_time].lteq(Time.current)) }
      scope :upcoming, -> { where(arel_table[:end_time].gteq(Time.current)) }
      scope :withdrawn, -> { where(state: "withdrawn") }
      scope :withdrawn, -> { where.not(withdrawn_at: nil) }
      scope :not_withdrawn, -> { where(withdrawn_at: nil) }
      scope :with_availability, lambda { |state_key|
        case state_key
        when "withdrawn"
          withdrawn
        else
          not_withdrawn
        end
      }
      scope_search_multi :with_any_date, [:upcoming, :past]
      scope :with_any_space, lambda { |*target_space|
        target_spaces = target_space.compact.compact_blank

        return self if target_spaces.blank? || target_spaces.include?("all")

        joins(:component).where(
          decidim_components: { participatory_space_type: target_spaces.map(&:classify) }
        )
      }

      scope :visible_for, lambda { |user|
        (all.distinct if user&.admin?) ||
          if user.present?
            (spaces = Decidim.participatory_space_registry.manifests.filter_map do |manifest|
              table_name = manifest.model_class_name.constantize.try(:table_name)
              next if table_name.blank?

              {
                name: table_name.singularize,
                class_name: manifest.model_class_name
              }
            end)
            (user_role_queries = spaces.map do |space|
              roles_table = "#{space[:name]}_user_roles"
              next unless connection.table_exists?(roles_table)

              "SELECT decidim_components.id FROM decidim_components
              WHERE CONCAT(decidim_components.participatory_space_id, '-', decidim_components.participatory_space_type)
              IN
              (SELECT CONCAT(#{roles_table}.#{space[:name]}_id, '-#{space[:class_name]}')
              FROM #{roles_table} WHERE #{roles_table}.decidim_user_id = ?)
              "
            end)

            query = "
              decidim_meetings_meetings.private_meeting = ?
              OR decidim_meetings_meetings.transparent = ?
              OR decidim_meetings_meetings.id IN (
                SELECT decidim_meetings_registrations.decidim_meeting_id FROM decidim_meetings_registrations WHERE decidim_meetings_registrations.decidim_user_id = ?
              )
              OR decidim_meetings_meetings.decidim_component_id IN (
                SELECT decidim_components.id FROM decidim_components
                WHERE CONCAT(decidim_components.participatory_space_id, '-', decidim_components.participatory_space_type)
                IN
                  (SELECT CONCAT(decidim_participatory_space_private_users.privatable_to_id, '-', decidim_participatory_space_private_users.privatable_to_type)
                  FROM decidim_participatory_space_private_users WHERE decidim_participatory_space_private_users.decidim_user_id = ?)
              )
            "
            if user_role_queries.any?
              query = "#{query} OR decidim_meetings_meetings.decidim_component_id IN
                (#{user_role_queries.compact.join(" UNION ")})
              "
            end

            where(Arel.sql(query).to_s, false, true, user.id, user.id, *user_role_queries.compact.map { user.id }).published.distinct
          else
            published.visible
          end
      }

      scope :visible, -> { where("decidim_meetings_meetings.private_meeting != ? OR decidim_meetings_meetings.transparent = ?", true, true) }

      scope :authored_by, ->(author) { where(decidim_author_id: author) }

      scope_search_multi :with_any_type, TYPE_OF_MEETING.keys

      searchable_fields({
                          scope_id: :decidim_scope_id,
                          participatory_space: { component: :participatory_space },
                          A: :title,
                          D: [:description, :address],
                          datetime: :start_time
                        },
                        index_on_create: ->(meeting) { meeting.visible? && meeting.published? },
                        index_on_update: ->(meeting) { meeting.visible? && meeting.published? })

      # we create a salt for the meeting only on new meetings to prevent changing old IDs for existing (Ether)PADs
      before_create :set_default_salt

      def self.export_serializer
        Decidim::Meetings::DownloadYourDataMeetingSerializer
      end

      def self.participants_iframe_embed_types
        iframe_embed_types.except(:open_in_live_event_page)
      end

      # Return registrations of a particular meeting made by users representing a group
      def user_group_registrations
        registrations.where.not(decidim_user_group_id: nil)
      end

      # Returns the presenter for this author, to be used in the views.
      # Required by ActsAsAuthor.
      def presenter
        Decidim::Meetings::MeetingPresenter.new(self)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::MeetingPresenter
      end

      def can_be_joined_by?(user)
        !started? && registrations_enabled? && can_participate?(user)
      end

      def can_register_invitation?(user)
        !closed? && registrations_enabled? &&
          can_participate_in_space?(user) && user_has_invitation_for_meeting?(user)
      end

      def closed?
        closed_at.present?
      end

      def started?
        start_time < Time.current
      end

      def past?
        end_time < Time.current
      end

      def emendation?
        false
      end

      def has_available_slots?
        return true if available_slots.zero?

        (available_slots - reserved_slots) > registrations.count
      end

      def remaining_slots
        available_slots - reserved_slots - registrations.count
      end

      def has_registration_for?(user)
        registrations.where(user:).any?
      end

      def maps_enabled?
        component.settings.maps_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` CommentableWithComponent concern method.
      def accepts_new_comments?
        commentable? && !component.current_settings.comments_blocked && comments_allowed?
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`
      def users_to_notify_on_comment_created
        followers
      end

      def can_participate?(user)
        can_participate_in_space?(user) && can_participate_in_meeting?(user)
      end

      def current_user_can_visit_meeting?(user)
        Decidim::Meetings::Meeting.visible_for(user).exists?(id:)
      end

      def iframe_access_level_allowed_for_user?(user)
        case iframe_access_level
        when "all"
          true
        when "signed_in"
          user.present?
        else
          has_registration_for?(user)
        end
      end

      # Return the duration of the meeting in minutes
      def meeting_duration
        @meeting_duration ||= ((end_time - start_time) / 1.minute).abs
      end

      def resource_visible?
        return false if hidden?

        !private_meeting? || transparent?
      end

      # Public: Checks if the author has withdrawn the meeting.
      #
      # Returns Boolean.
      def withdrawn?
        withdrawn_at.present?
      end

      # Checks whether the user can withdraw the given meeting.
      #
      # user - the user to check for withdrawability.
      # past meetings cannot be withdrawn
      def withdrawable_by?(user)
        user && !withdrawn? && !past? && authored_by?(user)
      end

      def withdraw!
        self.withdrawn_at = Time.zone.now
        save
      end

      # Overwrites method from Paddable to add custom rules in order to know
      # when to display a pad or not.
      def pad_is_visible?
        return false unless pad

        (start_time - Time.current) <= 24.hours
      end

      # Overwrites method from Paddable to add custom rules in order to know
      # when a pad is writable or not.
      def pad_is_writable?
        return false unless pad_is_visible?

        (Time.current - end_time) < 72.hours
      end

      def authored_proposals
        return [] unless Decidim::Meetings.enable_proposal_linking

        Decidim::Proposals::Proposal
          .joins(:coauthorships)
          .where(
            decidim_coauthorships: {
              decidim_author_type: "Decidim::Meetings::Meeting",
              decidim_author_id: id
            }
          )
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:description]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [author_name]
      end

      def has_contributions?
        !!contributions_count && contributions_count.positive?
      end

      def has_attendees?
        !!attendees_count && attendees_count.positive?
      end

      def live?
        start_time &&
          end_time &&
          Time.current >= (start_time - 10.minutes) &&
          Time.current <= end_time
      end

      def self.sort_by_translated_title_asc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:title], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("ASC")))
      end

      def self.sort_by_translated_title_desc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:title], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("DESC")))
      end

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      ransacker :id_string do
        Arel.sql(%{cast("decidim_meetings_meetings"."id" as text)})
      end

      ransacker :is_upcoming do
        Arel.sql("(start_time > NOW())")
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_type, :with_any_date, :with_any_space, :with_any_origin, :with_any_taxonomies, :with_any_global_category]
      end

      def self.ransackable_attributes(auth_object = nil)
        base = %w(description id_string search_text title)

        return base unless auth_object&.admin?

        base + %w(is_upcoming closed_at)
      end

      def self.ransackable_associations(_auth_object = nil)
        %w(taxonomies)
      end

      def self.ransack(params = {}, options = {})
        MeetingSearch.new(self, params, options)
      end

      private

      def can_participate_in_meeting?(user)
        return true unless private_meeting?
        return false unless user

        registrations.exists?(decidim_user_id: user.id)
      end

      def user_has_invitation_for_meeting?(user)
        return true unless private_meeting?
        return false unless user

        invites.exists?(decidim_user_id: user.id)
      end

      # salt is used to generate secure hash in pads
      def set_default_salt
        self.salt ||= Tokenizer.random_salt
      end
    end
  end
end
