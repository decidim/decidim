# frozen_string_literal: true
module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch
      attr_reader :feature, :page, :per_page

      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the proposals from.
      # page        - The page number to paginate the results.
      # random_seed - A random flaot number between -1 and 1 to be used as a random seed at the database.
      # per_page    - The number of proposals to return per page.
      def initialize(feature, page = nil, random_seed = nil, per_page = nil)
        @feature = feature
        @page = (page || 1).to_i
        @per_page = (per_page || 12).to_i
        @random_seed = random_seed.to_f
      end

      # Returns the random proposals for the current page.
      def proposals
        @proposals ||= Proposal.transaction do
          Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
          Proposal.where(feature: feature).reorder("RANDOM()").page(page).per(per_page).load
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
