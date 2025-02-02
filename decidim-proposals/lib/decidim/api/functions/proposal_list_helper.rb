# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalListHelper < Decidim::Core::ComponentListBase
      # only querying published posts
      def query_scope
        super.published
      end
    end
  end
end
