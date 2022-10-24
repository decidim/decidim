# frozen_string_literal: true

module Decidim
  module Initiatives
    # This custom Form builder add the fields needed to deal with
    # Initiative types.
    class InitiativesFilterFormBuilder < Decidim::FilterFormBuilder
      # Public: Generates a select field with the initiative types.
      #
      # name       - The name of the field (usually type_id)
      # collection - A collection of initiative types.
      # options    - An optional Hash with options:
      # - prompt   - An optional String with the text to display as prompt.
      #
      # Returns a String.
      def initiative_types_select(name, collection, options = {})
        selected = object.send(name)

        types = types_for_options_for_select(selected, collection)

        prompt = options.delete(:prompt)
        remote_path = options.delete(:remote_path) || false
        multiple = options.delete(:multiple) || false
        html_options = {
          multiple:,
          class: "select2",
          "data-remote-path" => remote_path,
          "data-placeholder" => prompt
        }

        select(name, @template.options_for_select(types, selected:), options, html_options)
      end

      private

      def types_for_options_for_select(selected, collection)
        if selected.present?
          if selected == "all"
            types = collection.all.map do |type|
              [type.title[I18n.locale.to_s], type.id]
            end
          else
            selected = selected.values if selected.is_a?(Hash)
            selected = [selected] unless selected.is_a?(Array)
            types = collection.where(id: selected.map(&:to_i)).map do |type|
              [type.title[I18n.locale.to_s], type.id]
            end
          end
        else
          types = []
        end
        types
      end
    end
  end
end
