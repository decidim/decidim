# frozen_string_literal: true

module Decidim
  module Votings
    # This helper include some methods for rendering votings dynamic maps.
    module MapHelper
      include Decidim::SanitizeHelper
      include Decidim::LayoutHelper

      def polling_station_data_for_map(polling_stations)
        polling_stations_geocoded = polling_stations.select(&:geocoded_and_valid?)
        polling_stations_geocoded.map do |polling_station|
          polling_station.slice(:latitude, :longitude, :address)
                         .merge(
                           title: translated_attribute(polling_station.title),
                           items: [{ icon: icon("map-line").html_safe, text: polling_station.address }].to_json
                         )
        end
      end
    end
  end
end
