# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the linked resource of a proposal.
    class ProposalLinkedResourcesCell < Decidim::ViewModel
      def show
        render if linked_resource
      end
    end
  end
end
