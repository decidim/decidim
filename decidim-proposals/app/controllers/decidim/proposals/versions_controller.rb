# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes CollaborativeDraft versions so users can see how a CollaborativeDraft
    # has been updated through time.
    class VersionsController < Decidim::Proposals::ApplicationController
      helper Decidim::TraceabilityHelper
      helper_method :current_version, :item

      private

      def item
        @item ||= CollaborativeDraft.where(component: current_component).find(params[:collaborative_draft_id])
      end

      def current_version
        return nil if params[:id].to_i < 1
        @current_version ||= item.versions[params[:id].to_i - 1]
      end
    end
  end
end
