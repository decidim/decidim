# frozen-string_literal: true

module Decidim
  module Proposals
    class PublishProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent

      private

      def i18n_scope
        return super unless participatory_space_event?

        "decidim.events.proposals.proposal_published_for_space"
      end

      def participatory_space_event?
        extra.dig(:participatory_space)
      end
    end
  end
end
