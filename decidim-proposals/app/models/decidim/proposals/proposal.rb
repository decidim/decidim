# frozen_string_literal: true

module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Coauthorable
      include Decidim::HasComponent
      include Decidim::Taxonomizable
      include Decidim::ScopableResource
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Proposals::CommentableProposal
      include Decidim::Searchable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Fingerprintable
      include Decidim::DownloadYourData
      include Decidim::Proposals::ParticipatoryTextSection
      include Decidim::Amendable
      include Decidim::NewsletterParticipant
      include Decidim::Randomable
      include Decidim::Endorsable
      include Decidim::Proposals::Evaluable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::FilterableResource
      include Decidim::SoftDeletable
      include Decidim::Publicable

      def assign_state(token)
        proposal_state = Decidim::Proposals::ProposalState.where(component:, token:).first

        self.proposal_state = proposal_state
      end

      translatable_fields :title, :body

      fingerprint fields: [:title, :body]

      amendable(
        fields: [:title, :body],
        form: "Decidim::Proposals::ProposalForm"
      )

      component_manifest_name "proposals"

      belongs_to :proposal_state,
                 class_name: "Decidim::Proposals::ProposalState",
                 foreign_key: "decidim_proposals_proposal_state_id",
                 inverse_of: :proposals,
                 optional: true,
                 counter_cache: true

      has_many :votes,
               -> { final },
               foreign_key: "decidim_proposal_id",
               class_name: "Decidim::Proposals::ProposalVote",
               dependent: :destroy,
               counter_cache: "proposal_votes_count"

      has_many :notes, foreign_key: "decidim_proposal_id", class_name: "ProposalNote", dependent: :destroy, counter_cache: "proposal_notes_count"

      validates :title, :body, presence: true

      geocoded_by :address

      scope :not_status, lambda { |status|
        joins(:proposal_state).where.not(decidim_proposals_proposal_states: { token: status })
      }

      scope :only_status, lambda { |status|
        joins(:proposal_state).where(decidim_proposals_proposal_states: { token: status })
      }

      scope :accepted, -> { state_published.only_status(:accepted) }
      scope :rejected, -> { state_published.only_status(:rejected) }
      scope :evaluating, -> { state_published.only_status(:evaluating) }

      scope :gamified, -> { only_status(:accepted).where(decidim_proposals_proposal_states: { gamified: true }) }

      scope :answered, -> { where.not(answered_at: nil) }
      scope :not_answered, -> { where(answered_at: nil) }

      scope :state_not_published, -> { where(state_published_at: nil) }
      scope :state_published, -> { where.not(state_published_at: nil) }

      scope :except_rejected, -> { state_published.not_status(:rejected).or(state_not_published) }

      scope :withdrawn, -> { where.not(withdrawn_at: nil) }
      scope :not_withdrawn, -> { where(withdrawn_at: nil) }

      scope :drafts, -> { where(published_at: nil) }
      scope :order_by_most_recent, -> { order(created_at: :desc) }

      scope :with_availability, lambda { |state_key|
        case state_key
        when "withdrawn"
          withdrawn
        else
          not_withdrawn
        end
      }

      scope :with_type, lambda { |type_key, user, component|
        case type_key
        when "proposals"
          only_amendables
        when "amendments"
          only_visible_emendations_for(user, component)
        else # Assume 'all'
          amendables_and_visible_emendations_for(user, component)
        end
      }

      scope :voted_by, lambda { |user|
        includes(:votes).where(decidim_proposals_proposal_votes: { decidim_author_id: user })
      }

      scope :sort_by_evaluation_assignments_count_asc, lambda {
        order(evaluation_assignments_count: :asc)
      }

      scope :sort_by_evaluation_assignments_count_desc, lambda {
        order(evaluation_assignments_count: :desc)
      }

      scope :state_eq, lambda { |state|
        return withdrawn if state == "withdrawn"

        only_status(state)
      }

      scope :with_any_state, lambda { |*value_keys|
        possible_scopes = [:state_not_published, :state_published]
        custom_states = Decidim::Proposals::ProposalState.distinct.pluck(:token)

        search_values = value_keys.compact.compact_blank

        conditions = possible_scopes.map do |scope|
          search_values.member?(scope.to_s) ? try(scope) : nil
        end.compact

        additional_conditions = search_values & custom_states
        conditions.push(state_published.only_status(additional_conditions)) if additional_conditions.any?

        return self unless conditions.any?

        scoped_query = where(id: conditions.shift)
        conditions.each do |condition|
          scoped_query = scoped_query.or(where(id: condition))
        end

        scoped_query
      }

      def self.with_evaluation_assigned_to(user, space)
        evaluator_roles = space.user_roles(:evaluator).where(user:)

        includes(:evaluation_assignments)
          .where(decidim_proposals_evaluation_assignments: { evaluator_role_id: evaluator_roles })
      end

      acts_as_list scope: :decidim_component_id

      searchable_fields({
                          scope_id: :decidim_scope_id,
                          participatory_space: { component: :participatory_space },
                          D: :body,
                          A: :title,
                          datetime: :published_at
                        },
                        index_on_create: ->(proposal) { proposal.official? },
                        index_on_update: ->(proposal) { proposal.visible? })

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ProposalPresenter
      end

      # Returns a collection scoped by an author.
      # Overrides this method in DownloadYourData to support Coauthorable.
      def self.user_collection(author)
        return unless author.is_a?(Decidim::User)

        joins(:coauthorships)
          .where(decidim_coauthorships: { coauthorable_type: name })
          .where("decidim_coauthorships.decidim_author_id = ? AND decidim_coauthorships.decidim_author_type = ? ", author.id, author.class.base_class.name)
      end

      def self.retrieve_proposals_for(component)
        Decidim::Proposals::Proposal.where(component:).joins(:coauthorships)
                                    .includes(:votes, :endorsements)
                                    .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                    .not_hidden
                                    .published
                                    .not_withdrawn
      end

      def self.newsletter_participant_ids(component)
        proposals = retrieve_proposals_for(component).uniq

        coauthors_recipients_ids = proposals.map { |p| p.notifiable_identities.pluck(:id) }.flatten.compact.uniq

        participants_has_voted_ids = Decidim::Proposals::ProposalVote.joins(:proposal).where(proposal: proposals).joins(:author).map(&:decidim_author_id).flatten.compact.uniq

        endorsements_participants_ids = Decidim::Endorsement.where(resource: proposals)
                                                            .where(decidim_author_type: "Decidim::UserBaseEntity")
                                                            .pluck(:decidim_author_id).to_a.compact.uniq

        commentators_ids = Decidim::Comments::Comment.user_commentators_ids_in(proposals)

        (endorsements_participants_ids + participants_has_voted_ids + coauthors_recipients_ids + commentators_ids).flatten.compact.uniq
      end

      # Public: Updates the vote count of this proposal.
      #
      # Returns nothing.
      # rubocop:disable Rails/SkipsModelValidations
      def update_votes_count
        update_columns(proposal_votes_count: votes.count)
      end
      # rubocop:enable Rails/SkipsModelValidations

      # Public: Check if the user has voted the proposal.
      #
      # Returns Boolean.
      def voted_by?(user)
        ProposalVote.where(proposal: self, author: user).any?
      end

      # Public: Returns the published state of the proposal.
      #
      # Returns Boolean.
      def state
        return amendment.state if emendation?
        return nil unless published_state? || withdrawn?

        proposal_state&.token || "not_answered"
      end

      # Public: Returns the internal state of the proposal.
      #
      # Returns Boolean.
      def internal_state
        return amendment.state if emendation?

        proposal_state&.token || "not_answered"
      end

      # Public: Checks if the organization has published the state for the proposal.
      #
      # Returns Boolean.
      def published_state?
        emendation? || state_published_at.present?
      end

      # Public: Checks if the organization has given an answer for the proposal.
      #
      # Returns Boolean.
      def answered?
        answered_at.present?
      end

      # Public: Checks if the author has withdrawn the proposal.
      #
      # Returns Boolean.
      def withdrawn?
        withdrawn_at.present?
      end

      # Public: Checks if the organization has accepted a proposal.
      #
      # Returns Boolean.
      def accepted?
        state == "accepted"
      end

      # Public: Checks if the organization has rejected a proposal.
      #
      # Returns Boolean.
      def rejected?
        state == "rejected"
      end

      # Public: Checks if the organization has marked the proposal as evaluating it.
      #
      # Returns Boolean.
      def evaluating?
        state == "evaluating"
      end

      # Returns the presenter for this author, to be used in the views.
      # Required by ResourceRenderer.
      def presenter
        Decidim::Proposals::ProposalPresenter.new(self)
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:title, :body]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      # Returns authors name or title in case it is a meeting
      def reported_searchable_content_extras
        [authors.map { |p| p.respond_to?(:name) ? p.name : p.title }.join("\n")]
      end

      # Public: Whether the proposal is official or not.
      def official?
        authors.first.is_a?(Decidim::Organization)
      end

      # Public: Whether the proposal is created in a meeting or not.
      def official_meeting?
        authors.first.instance_of?(Decidim::Meetings::Meeting)
      end

      # Public: The maximum amount of votes allowed for this proposal.
      #
      # Returns an Integer with the maximum amount of votes, nil otherwise.
      def maximum_votes
        maximum_votes = component.settings.threshold_per_proposal
        return nil if maximum_votes.zero?

        maximum_votes
      end

      # Public: The maximum amount of votes allowed for this proposal. 0 means infinite.
      #
      # Returns true if reached, false otherwise.
      def maximum_votes_reached?
        return false unless maximum_votes

        votes.count >= maximum_votes
      end

      # Public: Can accumulate more votes than maximum for this proposal.
      #
      # Returns true if can accumulate, false otherwise
      def can_accumulate_votes_beyond_threshold
        component.settings.can_accumulate_votes_beyond_threshold
      end

      # Checks whether the user can edit the given proposal.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        return true if draft? && created_by?(user)

        !published_state? && within_edit_time_limit? && !copied_from_other_component? && created_by?(user)
      end

      # Checks whether the user can withdraw the given proposal.
      #
      # user - the user to check for withdrawability.
      def withdrawable_by?(user)
        user && !withdrawn? && authored_by?(user) && !copied_from_other_component?
      end

      def withdraw!
        self.withdrawn_at = Time.zone.now
        save
      end

      # Public: Whether the proposal is a draft or not.
      def draft?
        published_at.nil?
      end

      def self.ransack(params = {}, options = {})
        ProposalSearch.new(self, params, options)
      end

      # method to filter by assigned evaluator role ID
      def self.evaluator_role_ids_has(value)
        query = <<-SQL.squish
        :value = any(
          (SELECT decidim_proposals_evaluation_assignments.evaluator_role_id
          FROM decidim_proposals_evaluation_assignments
          WHERE decidim_proposals_evaluation_assignments.decidim_proposal_id = decidim_proposals_proposals.id
          )
        )
        SQL
        where(query, value:)
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_origin, :with_any_state, :state_eq, :voted_by, :coauthored_by, :related_to, :with_any_taxonomies, :evaluator_role_ids_has]
      end

      # Create i18n ransackers for :title and :body.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :body]

      def self.ransackable_attributes(_auth_object = nil)
        %w(id_string search_text title body is_emendation comments_count proposal_votes_count published_at proposal_notes_count)
      end

      def self.ransackable_associations(_auth_object = nil)
        %w(taxonomies proposal_state)
      end

      ransacker :state_published do
        Arel.sql("CASE
          WHEN EXISTS (
            SELECT 1 FROM decidim_amendments
            WHERE decidim_amendments.decidim_emendation_type = 'Decidim::Proposals::Proposal'
            AND decidim_amendments.decidim_emendation_id = decidim_proposals_proposals.id
          ) THEN 0
          WHEN state_published_at IS NULL AND answered_at IS NOT NULL THEN 2
          WHEN state_published_at IS NOT NULL THEN 1
          ELSE 0 END
        ")
      end

      def self.sort_by_translated_title_asc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:title], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("ASC")))
      end

      def self.sort_by_translated_title_desc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:title], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("DESC")))
      end

      ransacker :title do
        Arel.sql(%{cast("decidim_proposals_proposals"."title" as text)})
      end

      ransacker :id_string do
        Arel.sql(%{cast("decidim_proposals_proposals"."id" as text)})
      end

      ransacker :is_emendation do |_parent|
        query = <<-SQL.squish
        (
          SELECT EXISTS (
            SELECT 1 FROM decidim_amendments
            WHERE decidim_amendments.decidim_emendation_type = 'Decidim::Proposals::Proposal'
            AND decidim_amendments.decidim_emendation_id = decidim_proposals_proposals.id
          )
        )
        SQL
        Arel.sql(query)
      end

      def self.export_serializer
        Decidim::Proposals::DownloadYourDataProposalSerializer
      end

      def self.download_your_data_images(user)
        user_collection(user).map { |p| p.attachments.collect(&:file) }
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      # Checks whether the proposal is inside the time window to be editable or not once published.
      def within_edit_time_limit?
        return true if draft?
        return true if component.settings.proposal_edit_time == "infinite"

        time_value, time_unit = component.settings.edit_time

        limit_time = case time_unit
                     when "minutes"
                       updated_at + time_value.minutes
                     when "hours"
                       updated_at + time_value.hours
                     else
                       updated_at + time_value.days
                     end

        Time.current < limit_time
      end

      def process_amendment_state_change!
        return withdraw! if amendment.withdrawn?
        return unless %w(accepted rejected evaluating).member?(amendment.state)

        PaperTrail.request(enabled: false) do
          assign_state(amendment.state)
          update!(state_published_at: Time.current)
        end
      end

      def user_has_actions?(user)
        return false if authors.include?(user)
        return false if user&.blocked?
        return false if user&.deleted?
        return false unless user&.confirmed?

        true
      end

      def actions_for_comment(comment, current_user)
        return if comment.commentable != self
        return unless authors.include?(current_user)
        return unless user_has_actions?(comment.author)

        if coauthor_invitations_for(comment.author).any?
          [
            {
              label: I18n.t("decidim.proposals.actions.cancel_coauthor_invitation"),
              url: EngineRouter.main_proxy(component).cancel_proposal_invite_coauthors_path(proposal_id: id, id: comment.author.id),
              icon: "user-forbid-line",
              method: :delete,
              data: { confirm: I18n.t("decidim.proposals.actions.cancel_coauthor_invitation_confirm") }
            }
          ]
        else
          [
            {
              label: I18n.t("decidim.proposals.actions.mark_as_coauthor"),
              url: EngineRouter.main_proxy(component).proposal_invite_coauthors_path(proposal_id: id, id: comment.author.id),
              icon: "user-add-line",
              method: :post,
              data: { confirm: I18n.t("decidim.proposals.actions.mark_as_coauthor_confirm") }
            }
          ]
        end
      end

      def coauthor_invitations_for(user)
        Decidim::Notification.where(event_class: "Decidim::Proposals::CoauthorInvitedEvent", resource: self, user:)
      end

      private

      def copied_from_other_component?
        linked_resources(:proposals, %w(splitted_from_component merged_from_component copied_from_component)).any?
      end
    end
  end
end
