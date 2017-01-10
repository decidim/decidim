# frozen_string_literal: true
module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the proposals from.
      # page        - The page number to paginate the results.
      # random_seed - A random flaot number between -1 and 1 to be used as a random seed at the database.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Proposal, options)
        @random_seed = options[:random_seed].to_f
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
