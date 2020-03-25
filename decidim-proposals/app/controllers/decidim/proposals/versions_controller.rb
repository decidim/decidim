# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Proposals versions so users can see how a Proposal/CollaborativeDraft
    # has been updated through time.
    class VersionsController < Decidim::Proposals::ApplicationController
      helper Decidim::TraceabilityHelper

      include Decidim::ApplicationHelper

      helper_method :current_version, :item

      private

      def item
        @item ||= if params[:proposal_id]
                    present(Proposal.where(component: current_component).find(params[:proposal_id]))
                  else
                    CollaborativeDraft.where(component: current_component).find(params[:collaborative_draft_id])
                  end
      end

      def current_version
        return nil unless params[:id].to_i.positive?

        @current_version ||= item.versions[params[:id].to_i - 1]
      end
    end
  end
end
