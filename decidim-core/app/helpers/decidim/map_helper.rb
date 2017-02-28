# frozen_string_literal: true
module Decidim
  # This helper include some methods for rendering resources static and dynamic maps.
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

    def dynamic_map_for(resource, &block)
      if Decidim.geocoder.present?
        map_html_options = {
          class: "google-map",
          id: "map",
          "data-here-app-id" => Decidim.geocoder[:here_app_id],
          "data-here-app-code" => Decidim.geocoder[:here_app_code]
        }
        content = capture { block.call }
        content_tag :div, class: "row column" do
          content_tag(:div, "", map_html_options) + content
        end
      end
    end
  end
end
