# frozen_string_literal: true

module Decidim
  module Log
    # This class takes a changeset from a `PaperTrail::Version` and
    # a field mapping and cleans the changeset so it can be easily
    # rendered in the log section. It is intended to be used by the
    # `Decidim::Log::BasePresenter` class, which handles most of the
    # work to render a log.
    #
    # Example:
    #
    #    version = resource.versions.last
    #    fields_mapping = { updated_at: :date, title: :string }
    #    i18n_labels_scope = "activemodel.attributes.my_resource"
    #
    #    DiffChangesetCalculator
    #      .new(version.changeset, fields_mapping, i18n_labels_scope)
    #      .changeset
    class DiffChangesetCalculator
      # original_changeset - a `changeset` from a PaperTrail::Version instance
      # fields_mapping - a Hash mapping attribute names and a type to render them
      # i18n_labels_scope - a String representing the I18n scope where the attribtue
      #   labels can be found
      def initialize(original_changeset, fields_mapping, i18n_labels_scope)
        @original_changeset = original_changeset
        @fields_mapping = fields_mapping
        @i18n_labels_scope = i18n_labels_scope
      end

      # Calculates the changeset that should be rendered, from the
      # `original_changeset` and the `fields_mapping` values.
      #
      # Returns an Array of Hashes.
      def changeset
        original_changeset.inject([]) do |diff, (attribute, values)|
          attribute = attribute.to_sym

          type = :default
          type = fields_mapping[attribute] unless fields_mapping.nil?

          if type.blank? || values[0] == values[1]
            diff
          else
            diff.concat(calculate_changeset(attribute, values, type))
          end
        end.compact
      end

      private

      attr_reader :fields_mapping, :original_changeset, :i18n_labels_scope

      # Private: Generates the data structure for the changeset attribute,
      # needed so that the attribute can be rendered in the diff.
      #
      # attribute - the name of the attribute
      # values - an Array of the attribute values: [old_value, new_value]
      # type - a symbol or a String representing the value type presenter
      #
      # Returns an array of hashes.
      def calculate_changeset(attribute, values, type)
        return generate_i18n_changeset(attribute, values, type) if type == :i18n

        generate_changeset(attribute, values, type)
      end

      # Private: Generates the data structure for an i18n attribute,
      # needed so that the attribute can be rendered in the diff.
      # Sets the label for the given attribute as: `AttributeName (locale)`.
      #
      # attribute - the name of the attribute
      # values - an Array of the attribute values: [old_value, new_value]
      # type - a symbol or a String representing the value type presenter
      #
      # Returns an array of hashes.
      def generate_i18n_changeset(attribute, values, type)
        values.map! do |value|
          value = value.is_a?(String) ? JSON.parse(value) : value
          value.is_a?(Hash) ? value : { I18n.default_locale.to_s => value }
        rescue JSON::ParserError
          { I18n.default_locale.to_s => value }
        end

        locales = values[0].keys | values[1].keys
        locales.flat_map do |locale|
          previous_value = values.first.try(:[], locale)
          new_value = values.last.try(:[], locale)
          if previous_value == new_value
            nil
          else
            label = generate_label(attribute, locale)
            generate_changeset(attribute, [previous_value, new_value], type, label)
          end
        end
      end

      # Private: Generates the structure needed for the given attribute,
      # values, type and label.
      #
      # attribute - the name of the attribute
      # values - an Array of the attribute values: [old_value, new_value]
      # type - a symbol or a String representing the value type presenter
      # label - the label for the current attribute
      #
      # Returns an array of Hashes.
      def generate_changeset(attribute, values, type, label = nil)
        [
          {
            attribute_name: attribute,
            label: label || generate_label(attribute),
            new_value: values[1],
            previous_value: values[0],
            type:
          }
        ]
      end

      # Generates the label for the given attribute. If the `locale` is set,
      # it appends the locale at the end: `AttributeName (LocaleName)`.
      #
      # attribute - A Symbol representing the attribute name. It will retrive
      #   this key from the I18n scope set at `i18n_labels_scope`.
      # locale - a String representing the name of the locale.
      #
      # Returns a String.
      def generate_label(attribute, locale = nil)
        label = if i18n_labels_scope
                  I18n.t(attribute, scope: i18n_labels_scope, default: attribute.to_s.humanize)
                else
                  attribute.to_s.humanize
                end
        return label unless locale

        locale_name = I18n.t("locale.name", locale:) if I18n.available_locales.include?(locale.to_sym)
        locale_name ||= locale

        "#{label} (#{locale_name})"
      end
    end
  end
end
