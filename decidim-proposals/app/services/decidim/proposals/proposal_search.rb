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
      # random_seed - A random flaot number between -1 and 1 to be used as a random seed at the database.
      def initialize(options = {})
        super(Proposal.all, options)
        @random_seed = options[:random_seed].to_f
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
            .where(decidim_proposals_proposal_votes: {
                     decidim_author_id: options[:current_user]
                   })
        else
          query
        end
      end

      # Returns the random proposals for the current page.
      def results
        @proposals ||= Proposal.transaction do
          Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
          super.reorder("RANDOM()").load
        end
      end

      # Returns the random seed used to randomize the proposals.
      def random_seed
        @random_seed = (rand * 2 - 1) if @random_seed == 0.0 || @random_seed > 1 || @random_seed < -1
        @random_seed
      end
    end
  end
end
