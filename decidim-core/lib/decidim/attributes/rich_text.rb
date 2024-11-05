# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to convert rich text strings in the database, i.e.
    # strings that originate from the editor.
    class RichText < Decidim::Attributes::CleanString
      def type
        :"decidim/attributes/rich_text"
      end

      # Serializes the value to the database.
      def serialize(value)
        serialize_value(value)
      end

      private

      # From form to database
      def serialize_value(value)
        return value unless value.is_a?(String)

        context = {}
        parsed = Decidim::ContentProcessor.parse_with_processor(:blob, value, context)
        parsed.rewrite
      end

      # From database to form
      def cast_value(value)
        clean_string = super
        return clean_string unless clean_string.is_a?(String)

        renderer = Decidim::ContentProcessor.renderer_klass(:blob).constantize.new(clean_string)
        renderer.render
      end
    end
  end
end
