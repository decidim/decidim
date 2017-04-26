# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalWidgetsController < Decidim::WidgetsController
      helper_method :model, :current_participatory_process
      helper Proposals::ApplicationHelper

      private

      def model
        @model ||= Proposal.where(feature: params[:feature_id]).find(params[:proposal_id])
      end

      def current_participatory_process
        @current_participatory_process ||= model.feature.participatory_process
      end

      def iframe_url
        @iframe_url ||= proposal_proposal_widget_url(model)
      end
    end
  end
end
