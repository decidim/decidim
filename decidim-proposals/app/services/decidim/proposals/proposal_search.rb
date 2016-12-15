# frozen_string_literal: true
module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch
      attr_reader :feature

      def initialize(feature, page, random_seed)
        @feature = feature
        @page = page.to_i
        @random_seed = random_seed.to_f
      end

      def proposals
        @proposals ||= Proposal.transaction do
          Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
          Proposal.where(feature: feature).reorder("RANDOM()").page(page).per(per_page).load
        end
      end

      private

      def random_seed
        @random_seed = (rand * 2 - 1) if @random_seed == 0.0
        @random_seed
      end

      def page
        @page || 1
      end

      def per_page
        12
      end
    end
  end
end
