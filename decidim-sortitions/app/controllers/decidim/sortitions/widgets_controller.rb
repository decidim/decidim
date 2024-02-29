# frozen_string_literal: true

module Decidim
  module Sortitions
    class WidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper
      helper Sortitions::SortitionsHelper

      def show
        enforce_permission_to :embed, :sortition, sortition: model if model

        super
      end

      private

      def model
        @model ||= Sortition.where(component: current_component).find(params[:sortition_id])
      end

      def iframe_url
        @iframe_url ||= sortition_widget_url(model)
      end

      def permission_class_chain
        [Decidim::Sortitions::Permissions]
      end
    end
  end
end
