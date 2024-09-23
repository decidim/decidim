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
        delegate :current_component, :content_tag, :asset_pack_path, to: :template

        # Displays the geocoding field element's markup for the view.
        #
        # @param object_name [String, Symbol] The name for the object for which
        #   the field is generated for.
        # @param method [String, Symbol] The method/property in the object that
        #   the field is for.
        # @param options [Hash] Extra options for the field.
        # @return [String] The field element's markup.
        def geocoding_field(object_name, method, options = {})
          return original_geocoding_field(object_name, method, options) unless show_my_location_button?

          append_assets
          template.snippets.add(:decidim_proposals_geocoding_scripts, template.append_javascript_pack_tag("decidim_proposals_geocoding"))

          options[:autocomplete] ||= "off"
          options[:class] ||= "input-group-field"

          template.content_tag(:div, class: "geocoding-container") do
            template.text_field(
              object_name,
              method,
              options.merge("data-decidim-geocoding" => view_options.to_json)
            ) +
              template.content_tag(:div, class: "input-group-button user-device-location") do
                template.content_tag(:button, class: "button button__sm md:button__sm button__text-secondary mt-2", type: "button", data: {
                                       input: "#{object_name}_#{method}",
                                       latitude: "#{object_name}_latitude",
                                       longitude: "#{object_name}_longitude",
                                       error_no_location: I18n.t("errors.no_device_location", scope: "decidim.proposals.forms"),
                                       error_unsupported: I18n.t("errors.device_not_supported", scope: "decidim.proposals.forms"),
                                       url: template.url_for(controller: "/decidim/proposals/geolocation", action: "locate")
                                     }) do
                  template.icon("map-pin-line", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_location", scope: "decidim.proposals.forms")}"
                end
              end
          end
        end

        alias original_geocoding_field geocoding_field

        private

        def show_my_location_button?
          return unless template.respond_to?(:current_component)

          Decidim::Proposals.show_my_location_button.include?(template.current_component.manifest_name.to_sym)
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
