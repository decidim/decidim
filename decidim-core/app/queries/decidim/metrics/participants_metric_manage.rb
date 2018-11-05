# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for Participant's registries
    class ParticipantsMetricManage < Decidim::MetricManage
      # Searches for Participants in the following actions
      #  - Create a proposal (Proposals)
      #  - Give support to a proposal (Proposals)
      #  - Endorse (Proposals)
      #  X- Create a debate (Debates)
      #  - Answer a survey (Surveys)
      #  - Leave a comment (Comments)
      #  X- Vote a participatory budgeting project (Budgets)

      AVAILABLE_COMPONENTS = %w(proposals debates surveys comments budgets).freeze

      def metric_name
        "participants"
      end

      def save
        return @registry if @registry
        @registry = []
        query.each do |key, results|
          cumulative_value = results[:cumulative]
          next if cumulative_value.zero?
          quantity_value = results[:quantity] || 0
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

        @query = retrieve_participatory_spaces.each_with_object({}) do |participatory_space, _grouped_participants|
          components = retrieve_components(participatory_space)
          components.each do |component|
            # puts "---------- #{component.manifest_name}"
            # puts send(:"retrieve_participants_for_#{component.manifest_name}", component)
            send(:"retrieve_participants_for_#{component.manifest_name}", component)
          end
          #   related_object = comment.root_commentable
          #   return grouped_comments unless related_object
          #
          #   group_key = generate_group_key(related_object)
          #   grouped_comments[group_key] ||= { cumulative: 0, quantity: 0 }
          #   grouped_comments[group_key][:cumulative] += 1
          #   grouped_comments[group_key][:quantity] += 1 if comment.created_at >= start_time
          #
          #   grouped_comments
        end

        @query
      end

      # Search for all Participatory Space manifests and then all records available
      # Limited to ParticipatoryProcesses only
      def retrieve_participatory_spaces
        Decidim.participatory_space_manifests.map do |space_manifest|
          next unless space_manifest.name == :participatory_processes # Temporal limitation
          space_manifest.participatory_spaces.call(@organization)
        end.flatten
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
        cumulative_users |= votes.collect(&:author).select { |u| u.class == Decidim::User }.uniq
        cumulative_users |= endorsements.collect(&:author).select { |u| u.class == Decidim::User }.uniq
        cumulative_users |= proposals.collect(&:authors).flatten.select { |u| u.class == Decidim::User }.uniq

        votes = votes.where("decidim_proposals_proposal_votes.created_at >= ?", start_time)
        endorsements = endorsements.where("decidim_proposals_proposal_endorsements.created_at >= ?", start_time)
        proposals = proposals.where("decidim_proposals_proposals.published_at >= ?", start_time)

        quantity_users = []
        quantity_users |= votes.collect(&:author).select { |u| u.class == Decidim::User }.uniq
        quantity_users |= endorsements.collect(&:author).select { |u| u.class == Decidim::User }.uniq
        quantity_users |= proposals.collect(&:authors).flatten.select { |u| u.class == Decidim::User }.uniq

        {
          cumulative_users: cumulative_users.collect(&:id),
          quantity_users: quantity_users.collect(&:id)
        }
      end

      def retrieve_participants_for_debates(component)
        debates = Decidim::Debates::Debate.where(component: component).joins(:component)
                                          .where("decidim_debates_debates.created_at <= ?", end_time)
                                          .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                          .where.not(author: nil)
        {
          cumulative_users: debates.collect(&:decidim_author_id),
          quantity_users: debates.where("decidim_debates_debates.created_at >= ?", start_time).collect(&:decidim_author_id)
        }
      end

      def retrieve_participants_for_surveys(_component)
        # surveys = Decidim::Surveys::Survey.where(component: component).joins(:component)
        raise "retrieve_participants_for_surveys"
      end

      def retrieve_participants_for_comments(_component)
        raise "retrieve_participants_for_comments"
      end

      def retrieve_participants_for_budgets(component)
        budgets = Decidim::Budgets::Order.where(component: component).joins(:component)
                                         .finished
                                         .where("decidim_budgets_orders.checked_out_at <= ?", end_time)
        {
          cumulative_users: budgets.collect(&:decidim_user_id),
          quantity_users: budgets.where("decidim_budgets_orders.checked_out_at >= ?", start_time).collect(&:decidim_user_id)
        }
      end
      # Decidim::Metrics::ParticipantsMetricManage.new("2018-01-01", Decidim::Organization.first).save
    end
  end
end
