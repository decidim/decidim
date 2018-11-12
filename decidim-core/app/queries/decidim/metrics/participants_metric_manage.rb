# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for Participant's registries
    class ParticipantsMetricManage < Decidim::MetricManage
      # Searches for Participants in the following actions
      #  Create a proposal (Proposals)
      #  Give support to a proposal (Proposals)
      #  Endorse (Proposals)
      #  Create a debate (Debates)
      #  Answer a survey (Surveys)
      #  Vote a participatory budgeting project (Budgets)
      #  Leave a comment (Comments)

      AVAILABLE_COMPONENTS = %w(proposals debates surveys budgets).freeze

      def metric_name
        "participants"
      end

      def save
        return @registry if @registry
        @registry = []
        query.each do |key, results|
          cumulative_value = results[:cumulative_users].count
          next if cumulative_value.zero?
          quantity_value = results[:quantity_users].count || 0
          space_type, space_id = key
          record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                         participatory_space_type: space_type, participatory_space_id: space_id,
                                                         organization: @organization)
          record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
          @registry << record
        end
        @registry.each(&:save!)
        @registry
      end

      private

      # Creates a Hashed structure with number of Participants grouped by
      #
      #  - ParticipatorySpace (type & ID)
      def query
        return @query if @query

        @query = retrieve_participatory_spaces.each_with_object({}) do |participatory_space, grouped_participants|
          key = [participatory_space.class.name, participatory_space.id]
          grouped_participants[key] = { cumulative_users: [], quantity_users: [] }
          components = retrieve_components(participatory_space)
          components.each do |component|
            component_participants = send(:"retrieve_participants_for_#{component.manifest_name}", component)
            grouped_participants[key].merge!(component_participants) { |_key, g_p, c_p| g_p | c_p }
          end
          comments_participants = retrieve_participants_for_comments(participatory_space)
          grouped_participants[key].merge!(comments_participants) { |_key, g_p, c_p| g_p | c_p }
          grouped_participants
        end
        @query
      end

      # Search for all Participatory Space manifests and then all records available
      # Limited to ParticipatoryProcesses only
      def retrieve_participatory_spaces
        Decidim.participatory_space_manifests.map do |space_manifest|
          next unless space_manifest.name == :participatory_processes # Temporal limitation
          space_manifest.participatory_spaces.call(@organization)
        end.flatten.compact
      end

      # Search for all components published, within a fixed list of available
      def retrieve_components(participatory_space)
        participatory_space.components.published.where(manifest_name: AVAILABLE_COMPONENTS)
      end

      def retrieve_participants_for_proposals(component)
        proposals = Decidim::Proposals::Proposal.where(component: component).joins(:component)
                                                .includes(:votes, :endorsements)
                                                .except_withdrawn

        votes = Decidim::Proposals::ProposalVote.joins(:proposal).where(proposal: proposals)
                                                .where("decidim_proposals_proposal_votes.created_at <= ?", end_time)
        endorsements = Decidim::Proposals::ProposalEndorsement.joins(:proposal).where(proposal: proposals)
                                                              .where("decidim_proposals_proposal_endorsements.created_at <= ?", end_time)
        proposals = proposals.where("decidim_proposals_proposals.published_at <= ?", end_time)

        cumulative_users = []
        cumulative_users |= votes.joins(:author).pluck(:decidim_author_id)
        cumulative_users |= endorsements.where(decidim_author_type: "Decidim::UserBaseEntity").pluck(:decidim_author_id)
        cumulative_users |= proposals.joins(:coauthorships)
                                     .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                     .pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

        votes = votes.where("decidim_proposals_proposal_votes.created_at >= ?", start_time)
        endorsements = endorsements.where("decidim_proposals_proposal_endorsements.created_at >= ?", start_time)
        proposals = proposals.where("decidim_proposals_proposals.published_at >= ?", start_time)

        quantity_users = []
        quantity_users |= votes.joins(:author).pluck(:decidim_author_id)
        quantity_users |= endorsements.where(decidim_author_type: "Decidim::UserBaseEntity").pluck(:decidim_author_id)
        quantity_users |= proposals.joins(:coauthorships)
                                   .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                   .pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

        {
          cumulative_users: cumulative_users.uniq,
          quantity_users: quantity_users.uniq
        }
      end

      def retrieve_participants_for_debates(component)
        debates = Decidim::Debates::Debate.where(component: component).joins(:component)
                                          .where("decidim_debates_debates.created_at <= ?", end_time)
                                          .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                          .where.not(author: nil)

        {
          cumulative_users: debates.pluck(:decidim_author_id),
          quantity_users: debates.where("decidim_debates_debates.created_at >= ?", start_time).pluck(:decidim_author_id)
        }
      end

      def retrieve_participants_for_surveys(component)
        surveys = Decidim::Surveys::Survey.joins(:component, :questionnaire).where(component: component)
        questionnaires = Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                                      .where(questionnaire_for_type: Decidim::Surveys::Survey.name, questionnaire_for_id: surveys.pluck(:id))

        answers = Decidim::Forms::Answer.joins(:questionnaire)
                                        .where(questionnaire: questionnaires)
                                        .where("decidim_forms_answers.created_at <= ?", end_time)

        {
          cumulative_users: answers.pluck(:decidim_user_id).uniq,
          quantity_users: answers.where("decidim_forms_answers.created_at >= ?", start_time).pluck(:decidim_user_id).uniq
        }
      end

      def retrieve_participants_for_budgets(component)
        budgets = Decidim::Budgets::Order.where(component: component).joins(:component)
                                         .finished
                                         .where("decidim_budgets_orders.checked_out_at <= ?", end_time)

        {
          cumulative_users: budgets.pluck(:decidim_user_id),
          quantity_users: budgets.where("decidim_budgets_orders.checked_out_at >= ?", start_time).pluck(:decidim_user_id)
        }
      end

      def retrieve_participants_for_comments(participatory_space)
        # This is bad!!! We don't know if Comments module is actual loaded
        # return {} unless Object.const_defined?('Decidim::Comments::Comment')

        cumulative_users = []
        quantity_users = []

        retrieve_comments_for_organization.each do |comment|
          related_object = comment.root_commentable
          next unless related_object
          next unless check_participatory_space(participatory_space, related_object)
          cumulative_users << comment.decidim_author_id
          quantity_users << comment.decidim_author_id if comment.created_at >= start_time
        end
        {
          cumulative_users: cumulative_users.uniq,
          quantity_users: quantity_users.uniq
        }
      end

      def check_participatory_space(participatory_space, related_object)
        return related_object.participatory_space == participatory_space if related_object.respond_to?(:participatory_space)
        return related_object == participatory_space if related_object.is_a?(Decidim::Participable)
        false
      end

      def retrieve_comments_for_organization
        user_ids = Decidim::User.select(:id).where(organization: @organization).collect(&:id)
        Decidim::Comments::Comment.includes(:root_commentable).not_hidden
                                  .where("decidim_comments_comments.created_at <= ?", end_time)
                                  .where("decidim_comments_comments.decidim_author_id IN (?)", user_ids)
      end
    end
  end
end
