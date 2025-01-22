# frozen_string_literal: true

module Decidim
  module Map
    # A base class for autocomplete geocoding functionality, common to all
    # autocomplete map services.
    class Autocomplete < Map::Frontend
      # A builder for the geocoding autocompletion to be attached to the views.
      # Provides all the necessary functionality to initialize the front-end
      # geocoding autocompletion functionality.
      class Builder < Decidim::Map::Frontend::Builder
        delegate :icon, :content_tag, :asset_pack_path, to: :template

        # Renders the geocoding field element for the view. If the component supports
        # geolocation (as determined by `show_my_location_button?`), the field will include
        # a button allowing the user to use their current location to autofill the address.
        # Otherwise, a standard geocoding input field is rendered without the location button.
        #
        # @param object_name [String, Symbol] The name of the object the field is being generated for.
        # @param method [String, Symbol] The specific attribute or property of the object.
        # @param options [Hash] Additional options for customizing the field's behavior and appearance.
        # @return [String] The HTML markup for the geocoding field.
        def geocoding_field(object_name, method, options = {})
          options[:autocomplete] ||= "off"
          append_assets

          if show_my_location_button?
            geocoding_field_with_location_button(object_name, method, options)
          else
            geocoding_field_without_location_button(object_name, method, options)
          end
        end

        private

        def geocoding_field_with_location_button(object_name, method, options)
          template.snippets.add(:decidim_geocoding_scripts, template.append_javascript_pack_tag("decidim_geocoding"))
          template.snippets.add(:decidim_geocoding_styles, template.append_stylesheet_pack_tag("decidim_geocoding"))

          template.content_tag(:div, class: "geocoding-container") do
            template.text_field(
              object_name,
              method,
              options.merge("data-decidim-geocoding" => view_options.to_json)
            ) +
              template.content_tag(:div, class: "input-group-button user-device-location") do
                template.content_tag(:button, class: "button button__sm md:button__sm button__text-secondary", type: "button", data: {
                                       input: "#{object_name}_#{method}",
                                       latitude: "#{object_name}_latitude",
                                       longitude: "#{object_name}_longitude",
                                       error_no_location: I18n.t("errors.no_device_location", scope: "decidim.proposals.forms"),
                                       error_unsupported: I18n.t("errors.device_not_supported", scope: "decidim.proposals.forms"),
                                       url: Decidim::Core::Engine.routes.url_helpers.locate_path
                                     }) do
                  icon("map-pin-line", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_location", scope: "decidim.proposals.forms")}"
                end
              end
          end
        end

        def geocoding_field_without_location_button(object_name, method, options)
          template.text_field(
            object_name,
            method,
            options.merge("data-decidim-geocoding" => view_options.to_json)
          )
        end

        def show_my_location_button?
          return unless template.respond_to?(:current_component)

          template.current_component.manifest_name.to_sym == :proposals
        end
      end

      # This module will be included in the main application's form builder in
      # order to provide the geocoding_field method for the normal form
      # builders. This allows you to include geocoding autocompletion in the
      # forms using the following code:
      #
      #   <%= form_for record do |form| %>
      #     <%= form.geocoding_field(:address) %>
      #   <% end %>
      module FormBuilder
        def geocoding_field(attribute, options = {}, geocoding_options = {})
          @autocomplete_utility ||= Decidim::Map.autocomplete(
            organization: @template.current_organization
          )

          return text_field(attribute, options) unless @autocomplete_utility

          # Decidim::Map::Autocomplete::Builder
          builder = @autocomplete_utility.create_builder(
            @template,
            geocoding_options
          )

          options = merge_geocoding_options(attribute, options)

          field(attribute, options) do |opts|
            builder.geocoding_field(
              @object_name,
              attribute,
              opts
            )
          end
        end

        private

        def merge_geocoding_options(attribute, options)
          options[:value] ||= object.send(attribute) if object.respond_to?(attribute)
          if object.respond_to?(:latitude) && object.respond_to?(:longitude) && object.latitude.present? && object.longitude.present?
            point = [object.latitude, object.longitude]
            options["data-coordinates"] ||= point.join(",")
          end
          options
        end
      end
    end
  end
end
