# frozen-string_literal: true

module Decidim
  module Proposals
    class EvaluatingProposalEvent < Decidim::Events::SimpleEvent
      def event_has_roles?
        true
      end
    end
  end
end
