# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalWidgetsController < Decidim::WidgetsController
      helper Proposals::ApplicationHelper

      private

      def model
        @model ||= Proposal.where(feature: params[:feature_id]).find(params[:proposal_id])
      end

      def iframe_url
        @iframe_url ||= proposal_proposal_widget_url(model)
      end
    end
  end
end
