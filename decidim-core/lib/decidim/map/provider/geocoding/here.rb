# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Geocoding
        # The geocoding utility class for the HERE geocoding service
        class Here < ::Decidim::Map::Geocoding
          # @see Decidim::Map::Geocoding#address
          def address(coordinates, options = {})
            # Pass in a radius of 50 meters as an extra attribute for the HERE
            # API. Also sort the results by distance and pass a maxresults
            # attribute of 5.
            results = search(coordinates + [50], {
              params: {
                sortby: :distance,
                maxresults: 5
              }
            }.merge(options))
            return if results.empty?

            # Always prioritize house number results, even if they are not as
            # close as street level matches.
            hn_result = results.find do |r|
              r.data["resultType"] == "houseNumber"
            end
            return hn_result.address if hn_result

            # Some of the matches that have "resultType" == "street" do not even
            # contain the street name unless they also have the "streets" key in
            # the "scoring" -> "fieldScore" attribute defined.
            street_result = results.find do |r|
              r.data["scoring"]["fieldScore"].has_key?("streets")
            end
            return street_result.address if street_result

            # Otherwise, sort the results based on their exact distances from
            # the given coordinates (default functionality).
            results.sort! do |result1, result2|
              dist1 = Geocoder::Calculations.distance_between(
                result1.coordinates,
                coordinates
              )
              dist2 = Geocoder::Calculations.distance_between(
                result2.coordinates,
                coordinates
              )

              dist1 <=> dist2
            end

            results.first.address
          end
        end
      end
    end
  end
end
