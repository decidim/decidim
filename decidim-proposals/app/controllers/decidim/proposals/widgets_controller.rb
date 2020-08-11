# frozen_string_literal: true

module Decidim
  module Proposals
    class WidgetsController < Decidim::WidgetsController
      helper Proposals::ApplicationHelper

      private

      def model
        @model ||= Proposal.where(component: params[:component_id]).find(params[:proposal_id])
      end

      def iframe_url
        @iframe_url ||= proposal_widget_url(model)
      end
    end
  end
end
