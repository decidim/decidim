# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts unique Participants on a participatory process or
    # participatory processes belonging to a participatory process group
    class StatsParticipantsCount < Rectify::Query
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::ParticipatoryProcess) ||
                        participatory_space.is_a?(Decidim::ParticipatoryProcessGroup) && participatory_space.participatory_processes.exists?

        new(participatory_space).query
      end

      def initialize(participatory_space)
        @participatory_space = participatory_space
      end

      def query
        [
          comments_query,
          debates_query,
          endorsements_query,
          project_supports_query,
          proposals_query,
          proposal_supports_query,
          survey_answer_query
        ].flatten.uniq.count
      end

      private

      attr_reader :participatory_space

      def participatory_space_ids
        @participatory_space_ids ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                       participatory_space.id
                                     else
                                       participatory_space.participatory_processes.pluck(:id)
                                     end
      end

      def comments_query
        Decidim::Comments::Comment
          .where(decidim_root_commentable_id: participatory_space_ids)
          .pluck(:decidim_author_id)
          .uniq
      end

      def debates_query
        Decidim::Debates::Debate
          .where(
            component: space_components,
            decidim_author_type: Decidim::UserBaseEntity.name
          )
          .not_hidden
          .pluck(:decidim_author_id)
          .uniq
      end

      def endorsements_query
        Decidim::Endorsement
          .where(resource: space_components)
          .pluck(:decidim_author_id)
          .uniq
      end

      def proposals_query
        Decidim::Coauthorship
          .where(
            coauthorable: proposals_components,
            decidim_author_type: Decidim::UserBaseEntity.name
          )
          .pluck(:decidim_author_id)
          .uniq
      end

      def proposal_supports_query
        Decidim::Proposals::ProposalVote
          .where(
            proposal: proposals_components
          )
          .final
          .pluck(:decidim_author_id)
          .uniq
      end

      def project_supports_query
        Decidim::Budgets::Order.joins(budget: [:component])
                               .where(budget: {
                                        decidim_components: { id: space_components.pluck(:id) }
                                      })
                               .pluck(:decidim_user_id)
                               .uniq
      end

      def survey_answer_query
        Decidim::Forms::Answer.newsletter_participant_ids(space_components)
      end

      def space_components
        @space_components ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                participatory_space.components
                              else
                                Decidim::Component.where(participatory_space: participatory_space.participatory_processes)
                              end
      end

      def proposals_components
        @proposals_components ||= Decidim::Proposals::FilteredProposals.for(space_components).published.not_hidden
      end
    end
  end
end
