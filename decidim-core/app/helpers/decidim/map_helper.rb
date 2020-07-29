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
      return unless map_utility_static

      map_url = map_utility_static.link(
        latitude: resource.latitude,
        longitude: resource.longitude,
        options: options
      )

      address_text = resource.try(:address)
      address_text ||= t("latlng_text", latitude: latitude, longitude: longitude, scope: "decidim.map.static")
      map_service_brand = t("map_service_brand", scope: "decidim.map.static")

      link_to map_url, target: "_blank", rel: "noopener" do
        image_tag decidim.static_map_path(sgid: resource.to_sgid.to_s), alt: "#{map_service_brand} - #{address_text}"
      end
    end

    def dynamic_map_for(options_or_markers = {}, html_options = {}, &block)
      return unless map_utility_dynamic

      options = {}
      if options_or_markers.is_a?(Array)
        options[:markers] = options_or_markers
        options[:popup_template_id] = "marker-popup"
      else
        options = options_or_markers
      end

      builder = map_utility_dynamic.create_builder(self, options)

      content_for :header_snippets, builder.stylesheet_snippets
      content_for :header_snippets, builder.javascript_snippets

      map_html_options = { id: "map", class: "google-map" }.merge(html_options)

      help = content_tag(:div, class: "map__help") do
        sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")
        link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "#map_bottom", class: "skip")

        sr_content + link
      end
      content_tag :div, class: "row column" do
        map = builder.map_element(map_html_options, &block)
        link = link_to("", "#", id: "map_bottom")

        help + map + link
      end
    end

    private

    def map_utility_dynamic
      @map_utility_dynamic ||= Decidim::Map.dynamic(
        organization: current_organization
      )
    end

    def map_utility_static
      @map_utility_static ||= Decidim::Map.static(
        organization: current_organization
      )
    end
  end
end
