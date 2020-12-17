# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalParser < Decidim::Admin::Import::Parser
      def self.resource_klass
        Decidim::Proposals::Proposal
      end
    end
  end
end
