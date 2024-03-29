# frozen_string_literal: true

module Decidim
  module Proposals
    class WidgetsController < Decidim::WidgetsController
      helper Proposals::ApplicationHelper

      def show
        enforce_permission_to :embed, :proposal, proposal: model if model

        super
      end

      private

      def model
        @model ||= Proposal.not_hidden.except_withdrawn.where(component: current_component).find(params[:proposal_id])
      end

      def iframe_url
        @iframe_url ||= proposal_widget_url(model)
      end

      def permission_class_chain
        [Decidim::Proposals::Permissions]
      end
    end
  end
end
