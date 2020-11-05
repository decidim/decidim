# frozen_string_literal: true

module Decidim
  module Debates
    class WidgetsController < Decidim::WidgetsController
      helper Debates::ApplicationHelper

      private

      def model
        @model ||= Debate.where(component: params[:component_id]).find(params[:debate_id])
      end

      def iframe_url
        @iframe_url ||= debate_widget_url(model)
      end
    end
  end
end
