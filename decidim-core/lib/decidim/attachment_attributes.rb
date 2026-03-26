# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A set of convenience methods to deal with attachment attributes for
  # models that may set the attachment records through the original model
  # (Decidim::Attachment) or through the user submitted form data (String).
  module AttachmentAttributes
    extend ActiveSupport::Concern

    class_methods do
      # Public: Mirrors the `attribute` interface to define attachment
      # attributes for form objects.
      #
      # name - The attribute's name
      #
      # Example:
      #
      #   attachments_attribute :photos
      #   # This will create two attributes of the following types:
      #   #   attribute :photos, Array[Integer]
      #   #   attribute :add_photos, Array
      #   # In addition, it will generate:
      #   #   - A setter that handles String (JSON/CSV), Integer, or Array inputs.
      #   #   - A getter that falls back to add_photos when the attribute is blank.
      #   #   - Private helpers for parsing and extracting IDs.
      #
      # Returns nothing.
      def attachments_attribute(name) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        attribute name, Array[Integer]
        attribute :"add_#{name}", Array

        # Setter: coerces String (JSON or comma-separated IDs) and bare Integer
        # values into the expected Array[Integer] format before delegating to super.
        define_method :"#{name}=" do |value|
          case value
          when String
            super(send(:"parse_string_#{name}", value))
          when Integer
            super([value])
          else
            super(value)
          end
        end

        # Getter: resolves stored integer IDs to Decidim::Attachment records,
        # caching the result on the instance. Falls back to extracting IDs from
        # add_<name> when the attribute itself is blank, then resolves those too.
        variable_name = "@#{name}_records"
        define_method name do
          return instance_variable_get(variable_name) if instance_variable_defined?(variable_name)

          original = @attributes[name.to_s].value_before_type_cast
          ids = original.is_a?(String) ? send(:"parse_string_#{name}", original) : super()
          ids = send(:"extract_ids_from_add_#{name}") if ids.blank? && send(:"add_#{name}").present?

          instance_variable_set(
            variable_name,
            ids.map do |attachment|
              if attachment.is_a?(Integer)
                Decidim::Attachment.find_by(id: attachment)
              else
                attachment
              end
            end.compact
          )
        end

        # Private helpers -------------------------------------------------------

        define_method :"extract_ids_from_add_#{name}" do
          send(:"add_#{name}")
            .select { |item| item.is_a?(Hash) && (item[:id].present? || item["id"].present?) }
            .map { |item| (item[:id] || item["id"]).to_i }
        end

        define_method :"parse_string_#{name}" do |value|
          return [] if value.blank?

          send(:"parse_#{name}_ids", value)
        end

        define_method :"parse_#{name}_ids" do |value|
          ids = begin
            Array(JSON.parse(value))
          rescue JSON::ParserError
            value.split(",").map(&:strip)
          end

          ids.map(&:to_i).reject(&:zero?)
        end

        private :"extract_ids_from_add_#{name}"
        private :"parse_string_#{name}"
        private :"parse_#{name}_ids"
      end
    end
  end
end
