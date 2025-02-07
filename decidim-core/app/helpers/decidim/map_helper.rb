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
    def static_map_link(resource, options = {}, map_html_options = {}, &)
      return unless resource.geocoded_and_valid?
      return unless map_utility_static || map_utility_dynamic

      address_text = resource.try(:address)
      address_text ||= t("latlng_text", latitude:, longitude:, scope: "decidim.map.static")
      map_service_brand = t("map_service_brand", scope: "decidim.map.static")

      if map_utility_static
        map_url = map_utility_static.link(
          latitude: resource.latitude,
          longitude: resource.longitude,
          options:
        )

        # Check that the static map utility actually returns a URL before
        # creating the static map utility. If it does not, the image would be
        # otherwise blank.
        if map_utility_static.url(latitude: resource.latitude, longitude: resource.longitude)
          html_options = {
            class: "static-map",
            target: "_blank",
            rel: "noopener",
            data: { "external-link": "text-only" }
          }.merge(map_html_options)
          return link_to(map_url, html_options) do
            # We also add the latitude and the longitude to prevent the Workbox cache to be overly aggressive when updating a map
            image_tag decidim.static_map_path(sgid: resource.to_sgid.to_s, latitude: resource.latitude, longitude: resource.longitude), alt: "#{map_service_brand} - #{address_text}"
          end
        end
      end

      # Fall back to the dynamic map utility in case static maps are not
      # provided.
      builder = map_utility_dynamic.create_builder(self, {
        type: :static,
        latitude: resource.latitude,
        longitude: resource.longitude,
        zoom: 15,
        title: "#{map_service_brand} - #{address_text}",
        link: map_url
      }.merge(options))

      builder.map_element(
        { class: "static-map", tabindex: "0" }.merge(map_html_options),
        &
      )
    end

    def dynamic_map_for(options_or_markers = {}, html_options = {}, &)
      return unless map_utility_dynamic

      options = {
        popup_template_id: "marker-popup"
      }
      if options_or_markers.is_a?(Array)
        options[:markers] = options_or_markers
      else
        options = options.merge(options_or_markers)
      end

      builder = map_utility_dynamic.create_builder(self, options)

      map_html_options = { id: "map" }.merge(html_options)
      bottom_id = "#{map_html_options[:id]}_bottom"

      help = content_tag(:div, class: "map__skip-container") do
        sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "sr-only")
        link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "##{bottom_id}", class: "map__skip")

        sr_content + link
      end

      map = builder.map_element(map_html_options, &)
      bottom = content_tag(:div, "", id: bottom_id)

      content_tag(:div, help + map + bottom)
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
