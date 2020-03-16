# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the linked resource of a proposal.
    class ProposalsPickerCell < Decidim::ViewModel
      def show
        render
      end

      alias component model

      def picker_path
        request.path
      end

      def decorated_proposals
        proposals.each do |proposal|
          yield Decidim::Proposals::ProposalPresenter.new(proposal)
        end
      end

      def proposals
        @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, component)&.order(id: :asc)
      end

      def proposals_collection_name
        Decidim::Proposals::Proposal.model_name.human(count: 2)
      end
    end
  end
end
