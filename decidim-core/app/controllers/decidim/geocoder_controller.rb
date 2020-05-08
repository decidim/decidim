# frozen_string_literal: true

module Decidim
  class GeocoderController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def search
      @search_string = params[:q]
      results = Geocoder.search(@search_string)
      render json: format_results(results)
    end

    private

    def format_results(results)
      results.map do |result|
        {
          full_address: result.address,
          coordinates: result.coordinates,
          address: result.data["address"]
        }
      end
    end
  end
end
