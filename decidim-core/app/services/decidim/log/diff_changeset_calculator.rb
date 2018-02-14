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
    #
    #    DiffChangesetCalculator
    #      .new(version.changeset, fields_mapping)
    #      .changeset
    class DiffChangesetCalculator
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
        # 1. get original changeset
        # 2. only keep fields in mapping
        # 3. flatten i18n fields
        # 4. remove i18n fields that haven't changed
        # 5. return correct structure
        original_changeset.inject([]) do |diff, (attribute, values)|
          attribute = attribute.to_sym

          type = :default
          type = fields_mapping[attribute] unless fields_mapping.nil?

          if type.blank?
            diff
          else
            diff.concat(calculate_changeset(attribute, values, type))
          end
        end.compact
      end

      private

      attr_reader :fields_mapping, :original_changeset, :i18n_labels_scope

      # Private: Generates the data structure for the changeset attribute,
      # needed so that the attribtue can be rendered in the diff.
      #
      # Returns an array of hashes.
      def calculate_changeset(attribute, values, type)
        return generate_i18n_changeset(attribute, values, type) if type == :i18n

        generate_changeset(attribute, values, type)
      end

      def generate_i18n_changeset(attribute, values, type)
        values.last.flat_map do |locale, _value|
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

      def generate_changeset(attribute, values, type, label = nil)
        [
          {
            attribute_name: attribute,
            label: label || generate_label(attribute),
            new_value: values[1],
            previous_value: values[0],
            type: type
          }
        ]
      end

      def generate_label(attribute, locale = nil)
        label = I18n.t(attribute, scope: i18n_labels_scope)
        return label unless locale

        locale_name = I18n.t("locale.name", locale: locale)
        "#{label} (#{locale_name})"
      end
    end
  end
end