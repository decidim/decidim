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
      return unless resource.geocoded?

      zoom = options[:zoom] || 17
      latitude = resource.latitude
      longitude = resource.longitude

      map_url = "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=#{zoom}/#{latitude}/#{longitude}"

      link_to map_url, target: "_blank" do
        image_tag decidim.static_map_path(sgid: resource.to_sgid.to_s)
      end
    end

    def dynamic_map_for(markers_data)
      return if Decidim.geocoder.blank?

      map_html_options = {
        class: "google-map",
        id: "map",
        "data-markers-data" => markers_data.to_json,
        "data-here-app-id" => Decidim.geocoder[:here_app_id],
        "data-here-app-code" => Decidim.geocoder[:here_app_code]
      }
      content = capture { yield }
      content_tag :div, class: "row column" do
        content_tag(:div, "", map_html_options) + content
      end
    end
  end
end
