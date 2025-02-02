# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalFinderHelper < Decidim::Core::ComponentFinderBase
      # only querying published posts
      def query_scope
        super.published
      end
    end
  end
end
