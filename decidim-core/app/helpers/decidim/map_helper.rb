# frozen_string_literal: true
module Decidim
  # This helper include some methods for rendering resources static maps.
  module MapHelper
    # Renders a link to openstreetmaps with the resource latitude and longitude.
    # The link's content is a static map image.
    #
    # resource - A geolocalizable resource
    # options - An optional hash of options (default: { zoom: 17 })
    #           * zoom: A number to represent the zoom value of the map
    def static_map_link(resource, options = {})
      if geolocalizable.geocoded?
        zoom = options[:zoom] || 17
        latitude = geolocalizable.latitude
        longitude = geolocalizable.longitude

        map_url = "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=#{zoom}/#{latitude}/#{longitude}"

        link_to map_url, target: "_blank" do
          image_tag decidim.static_map_path(sgid: geolocalizable.to_sgid.to_s)
        end
      end
    end
  end
end
