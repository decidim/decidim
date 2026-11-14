# frozen_string_literal: true

module Decidim
  module Proposals
    # Kept so notifications and jobs queued before the rename to
    # ProposalStatusChangedEvent keep working after upgrading.
    class ProposalStateChangedEvent < ProposalStatusChangedEvent
      def i18n_scope
        super.sub("proposal_state_changed", "proposal_status_changed")
      end
    end
  end
end
