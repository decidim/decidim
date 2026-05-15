# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to get rankings for a given proposal
      # ordered by some given criteria.
      #
      module ProposalRankingsHelper
        # Public: Gets the ranking for a given proposal, ordered by some given
        # criteria. Proposal is sorted amongst its own siblings.
        #
        # Returns a Hash with two keys:
        #   :ranking - an Integer representing the ranking for the given proposal.
        #     Ranking starts with 1.
        #   :total - an Integer representing the total number of ranked proposals.
        #
        # Examples:
        #   ranking_for(proposal, proposal_votes_count: :desc)
        #   ranking_for(proposal, likes_count: :desc)
        def ranking_for(proposal, order = {})
          siblings = Decidim::Proposals::Proposal.where(component: proposal.component)
          ranked = siblings.order([order, { id: :asc }])
          ranked_ids = ranked.pluck(:id)

          { ranking: ranked_ids.index(proposal.id) + 1, total: ranked_ids.count }
        end

        # Public: Gets the ranking for a given proposal, ordered by likes.
        def likes_ranking_for(proposal)
          ranking_for(proposal, likes_count: :desc)
        end

        # Public: Gets the ranking for a given proposal, ordered by votes.
        def votes_ranking_for(proposal)
          ranking_for(proposal, proposal_votes_count: :desc)
        end

        def i18n_likes_ranking_for(proposal)
          rankings = likes_ranking_for(proposal)

          I18n.t(
            "ranking",
            scope: "decidim.proposals.admin.proposals.show",
            ranking: rankings[:ranking],
            total: rankings[:total]
          )
        end

        def i18n_votes_ranking_for(proposal)
          rankings = votes_ranking_for(proposal)

          I18n.t(
            "ranking",
            scope: "decidim.proposals.admin.proposals.show",
            ranking: rankings[:ranking],
            total: rankings[:total]
          )
        end
      end
    end
  end
end
