# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class PollingStationsCell < Decidim::ViewModel
          include Decidim::MapHelper
          include Decidim::SanitizeHelper
          include Decidim::LayoutHelper
          include Decidim::IconHelper
          include Decidim::NeedsSnippets

          delegate :current_participatory_space,
                   :snippets,
                   to: :controller

          def show
            return if current_participatory_space.online_voting?

            render
          end

          private

          def geolocation_enabled?
            Decidim::Map.available?(:geocoding)
          end

          def polling_stations
            @polling_stations ||= current_participatory_space.polling_stations
          end

          def polling_stations_geocoded
            @polling_stations_geocoded ||= polling_stations.geocoded
          end

          def polling_stations_geocoded_data_for_map
            polling_stations_geocoded.map do |polling_station|
              polling_station_data_for_map(polling_station)
            end
          end

          def polling_station_data_for_map(polling_station)
            polling_station.slice(:latitude, :longitude, :address)
                           .merge(
                             title: translated_attribute(polling_station.title),
                             location: translated_attribute(polling_station.location),
                             locationHints: translated_attribute(polling_station.location_hints)
                           )
          end
        end
      end
    end
  end
end
