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
        # Displays the geocoding field element's markup for the view.
        #
        # @param object_name [String, Symbol] The name for the object for which
        #   the field is generated for.
        # @param method [String, Symbol] The method/property in the object that
        #   the field is for.
        # @param options [Hash] Extra options for the field.
        # @return [String] The field element's markup.
        def geocoding_field(object_name, method, options = {})
          options[:autocomplete] ||= "off"

          template.text_field(
            object_name,
            method,
            options.merge("data-decidim-geocoding" => view_options.to_json)
          )
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

          unless @template.snippets.any?(:geocoding_styles) || @template.snippets.any?(:geocoding_scripts)
            @template.snippets.add(:geocoding_styles, builder.stylesheet_snippets)
            @template.snippets.add(:geocoding_scripts, builder.javascript_snippets)

            # This will display the snippets in the <head> part of the page.
            @template.snippets.add(:head, @template.snippets.for(:geocoding_styles))
            # This will display the snippets in the bottom part of the page.
            @template.snippets.add(:foot, @template.snippets.for(:geocoding_scripts))
          end

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
