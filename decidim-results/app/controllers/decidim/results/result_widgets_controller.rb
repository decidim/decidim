module Decidim
  module Results
    class ResultWidgetsController < Decidim::WidgetsController
      helper_method :model

      private

      def model
        @model ||= Result.where(feature: params[:feature_id]).find(params[:result_id])
      end
    end
  end
end
