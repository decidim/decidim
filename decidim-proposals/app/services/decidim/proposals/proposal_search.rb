# frozen_string_literal: true
module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the proposals from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Proposal.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title ILIKE ?", "%#{search_text}%")
          .or(query.where("body ILIKE ?", "%#{search_text}%"))
      end

      # Handle the origin filter
      # The 'official' proposals doesn't have an author id
      def search_origin
        if origin == "official"
          query.where(decidim_author_id: nil)
        elsif origin == "citizenship"
          query.where.not(decidim_author_id: nil)
        else # Assume 'all'
          query
        end
      end

      # Handle the activity filter
      def search_activity
        if activity.include? "voted"
          query
            .includes(:votes)
            .where(decidim_proposals_proposal_votes: {
                     decidim_author_id: options[:current_user]
                   })
        else
          query
        end
      end

      # Handle the state filter
      def search_state
        if state == "accepted"
          query.accepted
        elsif state == "rejected"
          query.rejected
        else # Assume 'all'
          query
        end
      end
    end
  end
end
