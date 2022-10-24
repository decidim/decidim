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
          return link_to map_url, target: "_blank", rel: "noopener" do
            image_tag decidim.static_map_path(sgid: resource.to_sgid.to_s), alt: "#{map_service_brand} - #{address_text}"
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

      unless snippets.any?(:map_styles) || snippets.any?(:map_scripts)
        snippets.add(:map_styles, builder.stylesheet_snippets)
        snippets.add(:map_scripts, builder.javascript_snippets)

        # This will display the snippets in the <head> part of the page.
        snippets.add(:head, snippets.for(:map_styles))
        # This will display the snippets in the bottom part of the page.
        snippets.add(:foot, snippets.for(:map_scripts))
      end

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

      # The map snippets are stored to the snippets utility in order to ensure
      # that they are only loaded once during each page load. In case they were
      # loaded multiple times, the maps would break. We store the map assets to
      # a special "map" snippets category in order to avoid displaying them
      # multiple times. Then we inject them to the "head" category during the
      # first load which will actually display them in the <head> section of the
      # view.
      #
      # Ideally we would use Rails' native content_for here (which is exactly
      # for this purpose) but unfortunately it does not work in the cells which
      # also need to display maps.
      unless snippets.any?(:map_styles) || snippets.any?(:map_scripts)
        snippets.add(:map_styles, builder.stylesheet_snippets)
        snippets.add(:map_scripts, builder.javascript_snippets)

        # This will display the snippets in the <head> part of the page.
        snippets.add(:head, snippets.for(:map_styles))
        # This will display the snippets in the bottom part of the page.
        snippets.add(:foot, snippets.for(:map_scripts))
      end

      map_html_options = { id: "map", class: "google-map" }.merge(html_options)
      bottom_id = "#{map_html_options[:id]}_bottom"

      help = content_tag(:div, class: "map__help") do
        sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")
        link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "##{bottom_id}", class: "skip")

        sr_content + link
      end
      content_tag :div, class: "row column" do
        map = builder.map_element(map_html_options, &)
        bottom = content_tag(:div, "", id: bottom_id)

        help + map + bottom
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
