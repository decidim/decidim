# frozen_string_literal: true

module Decidim
  module Results
    class ResultWidgetsController < Decidim::WidgetsController
      helper_method :model

      private

      def model
        @model ||= Result.where(feature: params[:feature_id]).find(params[:result_id])
      end

      def iframe_url
        @iframe_url ||= result_result_widget_url(model)
      end
    end
  end
end
