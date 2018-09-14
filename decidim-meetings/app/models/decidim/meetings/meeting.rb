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
      include Decidim::ScopableComponent
      include Decidim::HasCategory
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Hashtaggable

      belongs_to :organizer, foreign_key: "organizer_id", class_name: "Decidim::User", optional: true
      has_many :registrations, class_name: "Decidim::Meetings::Registration", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_many :invites, class_name: "Decidim::Meetings::Invite", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_one :minutes, class_name: "Decidim::Meetings::Minutes", foreign_key: "decidim_meeting_id", dependent: :destroy
      has_one :agenda, class_name: "Decidim::Meetings::Agenda", foreign_key: "decidim_meeting_id", dependent: :destroy

      component_manifest_name "meetings"

      validates :title, presence: true
      validate :organizer_belongs_to_organization

      geocoded_by :address, http_headers: ->(proposal) { { "Referer" => proposal.component.organization.host } }

      scope :past, -> { where(arel_table[:end_time].lteq(Time.current)) }
      scope :upcoming, -> { where(arel_table[:start_time].gt(Time.current)) }

      scope :visible_meeting_for, lambda { |user|
                                    joins("LEFT JOIN decidim_meetings_registrations ON
                                    decidim_meetings_registrations.decidim_meeting_id = #{table_name}.id")
                                      .where("(private_meeting = ? and decidim_meetings_registrations.decidim_user_id = ?)
                                    or private_meeting = ? or (private_meeting = ? and transparent = ?)", true, user, false, true, true).distinct
                                  }

      searchable_fields({
                          scope_id: :decidim_scope_id,
                          participatory_space: { component: :participatory_space },
                          A: :title,
                          D: [:description, :address],
                          datetime: :start_time
                        },
                        index_on_create: ->(meeting) { meeting.visible? },
                        index_on_update: ->(meeting) { meeting.visible? })

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::MeetingPresenter
      end

      def can_be_joined_by?(user)
        !closed? && registrations_enabled? && can_participate?(user)
      end

      def closed?
        closed_at.present?
      end

      def has_available_slots?
        return true if available_slots.zero?
        (available_slots - reserved_slots) > registrations.count
      end

      def remaining_slots
        available_slots - reserved_slots - registrations.count
      end

      def has_registration_for?(user)
        registrations.where(user: user).any?
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !component.current_settings.comments_blocked
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

      # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      def can_participate?(user)
        return true unless participatory_space.try(:private_space?) || private_meeting?
        return true if (participatory_space.try(:private_space?) &&
                        participatory_space.users.include?(user)) ||
                       (private_meeting? && registrations.exists?(decidim_user_id: user.try(:id)))
        return false if (participatory_space.try(:private_space?) &&
                        participatory_space.try(:transparent?)) ||
                        (private_meeting? && transparent?)
      end
      # rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity

      def organizer_belongs_to_organization
        return if !organizer || !organization
        errors.add(:organizer, :invalid) unless organizer.organization == organization
      end

      def official?
        organizer.nil?
      end

      def current_user_can_visit_meeting?(current_user)
        (private_meeting? && registrations.exists?(decidim_user_id: current_user.try(:id))) ||
          !private_meeting? || (private_meeting? && transparent?)
      end

      # Return the duration of the meeting in minutes
      def meeting_duration
        @meeting_duration ||= ((end_time - start_time) / 1.minute).abs
      end

      def resource_visible?
        !private_meeting? || transparent?
      end
    end
  end
end
