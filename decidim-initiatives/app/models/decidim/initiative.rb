# frozen_string_literal: true

module Decidim
  # The data store for a Initiative in the Decidim::Initiatives component.
  class Initiative < ApplicationRecord
    include ActiveModel::Dirty
    include Decidim::Authorable
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::ScopableParticipatorySpace
    include Decidim::Comments::Commentable
    include Decidim::Followable
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Initiatives::InitiativeSlug
    include Decidim::Resourceable
    include Decidim::HasReference
    include Decidim::Randomable
    include Decidim::Searchable
    include Decidim::Initiatives::HasArea
    include Decidim::TranslatableResource
    include Decidim::HasResourcePermission
    include Decidim::HasArea
    include Decidim::FilterableResource
    include Decidim::Reportable

    translatable_fields :title, :description, :answer

    delegate :type, :scope, :scope_name, :supports_required, to: :scoped_type, allow_nil: true
    delegate :document_number_authorization_handler, :promoting_committee_enabled?, :attachments_enabled?,
             :promoting_committee_enabled?, :custom_signature_end_date_enabled?, :area_enabled?, to: :type
    delegate :name, to: :area, prefix: true, allow_nil: true

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :scoped_type,
               class_name: "Decidim::InitiativesTypeScope",
               inverse_of: :initiatives

    has_many :votes,
             foreign_key: "decidim_initiative_id",
             class_name: "Decidim::InitiativesVote",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :committee_members,
             foreign_key: "decidim_initiatives_id",
             class_name: "Decidim::InitiativesCommitteeMember",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :components, as: :participatory_space, dependent: :destroy

    # This relationship exists only by compatibility reasons.
    # Initiatives are not intended to have categories.
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    enum signature_type: [:online, :offline, :any], _suffix: true
    enum state: [:created, :validating, :discarded, :published, :rejected, :accepted]

    validates :title, :description, :state, :signature_type, presence: true
    validates :hashtag,
              uniqueness: { allow_blank: true, case_sensitive: false }

    validate :signature_type_allowed

    scope :open, lambda {
      where.not(state: [:discarded, :rejected, :accepted, :created])
           .currently_signable
    }
    scope :closed, lambda {
      where(state: [:discarded, :rejected, :accepted])
        .or(currently_unsignable)
    }
    scope :published, -> { where.not(published_at: nil) }
    scope :with_state, ->(state) { where(state:) if state.present? }

    scope_search_multi :with_any_state, [:accepted, :rejected, :answered, :open, :closed]

    scope :currently_signable, lambda {
      where("signature_start_date <= ?", Date.current)
        .where("signature_end_date >= ?", Date.current)
    }
    scope :currently_unsignable, lambda {
      where("signature_start_date > ?", Date.current)
        .or(where("signature_end_date < ?", Date.current))
    }

    scope :answered, -> { where.not(answered_at: nil) }

    scope :public_spaces, -> { published }
    scope :signature_type_updatable, -> { created }

    scope :order_by_most_recent, -> { order(created_at: :desc) }
    scope :order_by_supports, -> { order(Arel.sql("(coalesce((online_votes->>'total')::int,0) + coalesce((offline_votes->>'total')::int,0)) DESC")) }
    scope :order_by_most_recently_published, -> { order(published_at: :desc) }
    scope :order_by_most_commented, -> { order(comments_count: :desc) }
    scope :future_spaces, -> { none }
    scope :past_spaces, -> { closed }

    scope :with_any_type, lambda { |*original_type_ids|
      type_ids = original_type_ids.flatten
      return self if type_ids.include?("all")

      types = InitiativesTypeScope.where(decidim_initiatives_types_id: type_ids).pluck(:id)
      where(scoped_type: types)
    }

    # Redefine the with_any_scope method as the initiative scope is defined by
    # the initiative type scope.
    scope :with_any_scope, lambda { |*original_scope_ids|
      scope_ids = original_scope_ids.flatten
      return self if scope_ids.include?("all")

      clean_scope_ids = scope_ids

      conditions = []
      conditions << "decidim_initiatives_type_scopes.decidim_scopes_id IS NULL" if clean_scope_ids.delete("global")
      conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

      joins(:scoped_type).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
    }

    scope :authored_by, lambda { |author|
      co_authoring_initiative_ids = Decidim::InitiativesCommitteeMember.where(
        decidim_users_id: author
      ).pluck(:decidim_initiatives_id)

      where(
        decidim_author_id: author,
        decidim_author_type: Decidim::UserBaseEntity.name
      ).or(
        where(id: co_authoring_initiative_ids)
      )
    }

    before_update :set_offline_votes_total
    after_commit :notify_state_change
    after_create :notify_creation

    searchable_fields({
                        participatory_space: :itself,
                        A: :title,
                        D: :description,
                        datetime: :published_at
                      },
                      index_on_create: ->(_initiative) { false },
                      # is Resourceable instead of ParticipatorySpaceResourceable so we cannot use `visible?`
                      index_on_update: ->(initiative) { initiative.published? })

    def self.log_presenter_class_for(_log)
      Decidim::Initiatives::AdminLog::InitiativePresenter
    end

    def self.ransackable_scopes(_auth_object = nil)
      [:with_any_state, :with_any_type, :with_any_scope, :with_any_area]
    end

    # Public: Overrides participatory space's banner image with the banner image defined
    # for the initiative type.
    #
    # Returns Decidim::BannerImageUploader
    def banner_image
      type.attached_uploader(:banner_image)
    end

    # Public: Whether the object's comments are visible or not.
    def commentable?
      type.comments_enabled?
    end

    # Public: Check if an initiative has been created by an individual person.
    # If it is false, then it has been created by an authorized organization.
    #
    # Returns a Boolean
    def created_by_individual?
      decidim_user_group_id.nil?
    end

    # Public: check if an initiative is open
    #
    # Returns a Boolean
    def open?
      !closed?
    end

    # Public: Checks if an initiative is closed. An initiative is closed when
    # at least one of the following conditions is true:
    #
    # * It has been discarded.
    # * It has been rejected.
    # * It has been accepted.
    # * Signature collection period has finished.
    #
    # Returns a Boolean
    def closed?
      discarded? || rejected? || accepted? || !votes_enabled?
    end

    # Public: Returns the author name. If it has been created by an organization it will
    # return the organization's name. Otherwise it will return author's name.
    #
    # Returns a string
    def author_name
      user_group&.name || author.name
    end

    # Public: Overrides the `reported_attributes` Reportable concern method.
    def reported_attributes
      [:title, :description]
    end

    def votes_enabled?
      published? &&
        signature_start_date <= Date.current &&
        signature_end_date >= Date.current
    end

    # Public: Check if the user has voted the question.
    #
    # Returns Boolean.
    def voted_by?(user)
      votes.where(author: user).any?
    end

    # Public: Checks if the organization has given an answer for the initiative.
    #
    # Returns a Boolean.
    def answered?
      answered_at.present?
    end

    # Public: Overrides scopes enabled flag available in other models like
    # participatory space or assemblies. For initiatives it will not be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled?
      true
    end

    # Public: Overrides scopes enabled attribute value.
    # For initiatives it will not be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled
      true
    end

    # Public: Publishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      return false if published?

      update(
        published_at: Time.current,
        state: "published",
        signature_start_date: Date.current,
        signature_end_date: signature_end_date || (Date.current + Decidim::Initiatives.default_signature_time_period_length)
      )
    end

    # Public: Unpublishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      return false unless published?

      update(published_at: nil, state: "discarded")
    end

    # Public: Returns wether the signature interval is already defined or not.
    def has_signature_interval_defined?
      signature_end_date.present? && signature_start_date.present?
    end

    # Public: Returns the hashtag for the initiative.
    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    # Public: Calculates the number of total current supports.
    #
    # Returns an Integer.
    def supports_count
      online_votes_count + offline_votes_count
    end

    # Public: Calculates the number of current supports for a scope.
    #
    # Returns an Integer.
    def supports_count_for(scope)
      online_votes_count_for(scope) + offline_votes_count_for(scope)
    end

    # Public: Calculates the number of supports required to accept the initiative for a scope.
    #
    # Returns an Integer.
    def supports_required_for(scope)
      initiative_type_scopes.find_by(decidim_scopes_id: scope&.id).supports_required
    end

    # Public: Returns the percentage of required supports reached
    def percentage
      [supports_count * 100 / supports_required, 100].min
    end

    # Public: Whether the supports required objective has been reached
    def supports_goal_reached?
      votable_initiative_type_scopes.map(&:scope).all? { |scope| supports_goal_reached_for?(scope) }
    end

    # Public: Whether the supports required objective has been reached for a scope
    def supports_goal_reached_for?(scope)
      supports_count_for(scope) >= supports_required_for(scope)
    end

    # Public: Calculates all the votes across all the scopes.
    #
    # Returns an Integer.
    def online_votes_count
      return 0 if offline_signature_type?

      online_votes["total"].to_i
    end

    def offline_votes_count
      return 0 if online_signature_type?

      offline_votes["total"].to_i
    end

    def online_votes_count_for(scope)
      return 0 if offline_signature_type?

      scope_key = (scope&.id || "global").to_s

      (online_votes || {}).fetch(scope_key, 0).to_i
    end

    def offline_votes_count_for(scope)
      return 0 if online_signature_type?

      scope_key = (scope&.id || "global").to_s

      (offline_votes || {}).fetch(scope_key, 0).to_i
    end

    def update_online_votes_counters
      online_votes = votes.group(:scope).count.each_with_object({}) do |(scope, count), counters|
        counters[scope&.id || "global"] = count
        counters["total"] ||= 0
        counters["total"] += count
      end

      # rubocop:disable Rails/SkipsModelValidations
      update_column("online_votes", online_votes)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def set_offline_votes_total
      return if offline_votes.blank?

      offline_votes["total"] = offline_votes[scope&.id.to_s] || offline_votes["global"]
    end

    # Public: Finds all the InitiativeTypeScopes that are eligible to be voted by a user.
    # Usually this is only the `scoped_type` but voting on children of the scoped type is
    # enabled we have to filter all the available scopes in the initiative type to select
    # the ones that are a descendant of the initiative type.
    #
    # Returns an Array of Decidim::InitiativesScopeType.
    def votable_initiative_type_scopes
      return Array(scoped_type) unless type.child_scope_threshold_enabled?

      initiative_type_scopes.select do |initiative_type_scope|
        initiative_type_scope.scope.present? && (scoped_type.global_scope? || scoped_type.scope.ancestor_of?(initiative_type_scope.scope))
      end.prepend(scoped_type).uniq
    end

    # Public: Overrides slug attribute from participatory processes.
    def slug
      slug_from_id(id)
    end

    def to_param
      slug
    end

    # Public: Overrides the `comments_have_alignment?`
    # Commentable concern method.
    def comments_have_alignment?
      true
    end

    # Public: Overrides the `comments_have_votes?` Commentable concern method.
    def comments_have_votes?
      true
    end

    # Public:  Checks if user is the author or is part of the promotal committee
    # of the initiative.
    #
    # Returns a Boolean.
    def has_authorship?(user)
      return true if author.id == user.id

      committee_members.approved.where(decidim_users_id: user.id).any?
    end

    def author_users
      [author].concat(committee_members.excluding_author.map(&:user))
    end

    def accepts_offline_votes?
      published? && (offline_signature_type? || any_signature_type?)
    end

    def accepts_online_votes?
      votes_enabled? && (online_signature_type? || any_signature_type?)
    end

    def accepts_online_unvotes?
      accepts_online_votes? && type.undo_online_signatures_enabled?
    end

    def minimum_committee_members
      type.minimum_committee_members || Decidim::Initiatives.minimum_committee_members
    end

    def enough_committee_members?
      committee_members.approved.count >= minimum_committee_members
    end

    def missing_committee_members
      minimum_committee_members - committee_members.approved.count
    end

    def component
      nil
    end

    # Public: Checks if the type the initiative belongs to enables SMS code
    # verification step. Tis configuration is ignored if the organization
    # does not have the sms authorization available
    #
    # Returns a Boolean
    def validate_sms_code_on_votes?
      organization.available_authorizations.include?("sms") && type.validate_sms_code_on_votes?
    end

    # Public: Returns an empty object. This method should be implemented by
    # `ParticipatorySpaceResourceable`, but for some reason this model does not
    # implement this interface.
    def user_role_config_for(_user, _role_name)
      Decidim::ParticipatorySpaceRoleConfig::Base.new(:empty_role_name)
    end

    # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
    def allow_resource_permissions?
      true
    end

    def user_allowed_to_comment?(user)
      ActionAuthorizer.new(user, "comment", self, nil).authorize.ok?
    end

    def self.ransack(params = {}, options = {})
      Initiatives::InitiativeSearch.new(self, params, options)
    end

    private

    # Private: This is just an alias because the naming on InitiativeTypeScope
    # is very confusing. The `scopes` method does not return Decidim::Scope but
    # Decidim::InitiativeTypeScopes.
    #
    # ¯\_(ツ)_/¯
    #
    # Returns an Array of Decidim::InitiativesScopeType.
    def initiative_type_scopes
      type.scopes
    end

    # Private: A validator that verifies the signature type is allowed by the InitiativeType.
    def signature_type_allowed
      return if published?

      errors.add(:signature_type, :invalid) if type.allowed_signature_types_for_initiatives.exclude?(signature_type)
    end

    def notify_state_change
      return unless saved_change_to_state?

      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end

    def notify_creation
      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end

    # Allow ransacker to search for a key in a hstore column (`title`.`en`)
    [:title, :description].each { |column| ransacker_i18n(column) }

    # Alias search_text as a grouped OR query with all the text searchable fields.
    ransack_alias :search_text, :id_string_or_title_or_description_or_author_name_or_author_nickname

    # Allow ransacker to search on an Enum Field
    ransacker :state, formatter: proc { |int| states[int] }

    ransacker :type_id do
      Arel.sql("decidim_initiatives_type_scopes.decidim_initiatives_types_id")
    end

    # method for sort_link by number of supports
    ransacker :supports_count do
      Arel.sql("(coalesce((online_votes->>'total')::int,0) + coalesce((offline_votes->>'total')::int,0))")
    end

    ransacker :id_string do
      Arel.sql(%{cast("decidim_initiatives"."id" as text)})
    end

    ransacker :author_name do
      Arel.sql("decidim_users.name")
    end

    ransacker :author_nickname do
      Arel.sql("decidim_users.nickname")
    end
  end
end
