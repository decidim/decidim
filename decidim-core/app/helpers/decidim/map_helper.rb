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

      address_text = resource.try(:address)
      address_text ||= t("latlng_text", latitude: latitude, longitude: longitude, scope: "decidim.map.static")
      map_service_brand = t("map_service_brand", scope: "decidim.map.static")

      map_url = "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=#{zoom}/#{latitude}/#{longitude}"

      link_to map_url, target: "_blank", rel: "noopener" do
        image_tag decidim.static_map_path(sgid: resource.to_sgid.to_s), alt: "#{map_service_brand} - #{address_text}"
      end
    end

    def dynamic_map_for(markers_data)
      return if Decidim.geocoder.blank?

      map_html_options = {
        class: "google-map",
        id: "map",
        "data-markers-data" => markers_data.to_json
      }

      if Decidim.geocoder[:here_api_key]
        map_html_options["data-here-api-key"] = Decidim.geocoder[:here_api_key]
      else
        # Compatibility mode for old api_id/app_code configurations
        map_html_options["data-here-app-id"] = Decidim.geocoder[:here_app_id]
        map_html_options["data-here-app-code"] = Decidim.geocoder[:here_app_code]
      end

      content = capture { yield }.html_safe
      help = content_tag(:div, class: "map__help") do
        sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")
        link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "#map_bottom", class: "skip")

        sr_content + link
      end
      content_tag :div, class: "row column" do
        map = content_tag(:div, "", map_html_options)
        link = link_to("", "#", id: "map_bottom")

        help + map + content + link
      end
    end
  end
end
