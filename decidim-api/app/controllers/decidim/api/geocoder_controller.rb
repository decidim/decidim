# frozen_string_literal: true

module Decidim
  module Api
    class GeocoderController < Api::ApplicationController
      def search
        if Decidim.geocoder.blank?
          render json: { error: { message: t("decidim.geocoder.not_configured") } }
        else
          @search_string = params[:term]
          results = Geocoder.search(@search_string, language: params.dig(:locale) || I18n.locale)
          render json: format_results(results)
        end
      end

      private

      def format_results(results)
        results.map do |result|
          {
            label: result.address,
            value: result.address
          }
        end
      end
    end
  end
end
