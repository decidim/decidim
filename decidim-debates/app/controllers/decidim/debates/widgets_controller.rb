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
        @model ||= Debate.not_hidden.where(component: current_component).find(params[:debate_id])
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
