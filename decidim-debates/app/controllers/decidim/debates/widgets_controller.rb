# frozen_string_literal: true

module Decidim
  module Debates
    class WidgetsController < Decidim::WidgetsController
      helper Debates::ApplicationHelper

      def show
        enforce_permission_to :embed, :debate, debate: model if model

        super
      end

      private

      def model
        @model ||= Debate.where(organization: current_organization).where(component: params[:component_id]).find(params[:debate_id])
      end

      def iframe_url
        @iframe_url ||= debate_widget_url(model)
      end

      def permission_class_chain
        [Decidim::Debates::Permissions]
      end
    end
  end
end
