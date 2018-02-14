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
      def initialize(original_changeset, fields_mapping)
        @original_changeset = original_changeset
        @fields_mapping = fields_mapping
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
          type = fields_mapping[attribute]

          if type.blank?
            diff
          else
            diff.concat(generate_changeset(attribute, values, type, diff))
          end
        end
      end

      private

      attr_reader :fields_mapping, :original_changeset

      # Private: Generates the data structure for the changeset attribute,
      # needed so that the attribtue can be rendered in the diff.
      #
      # Returns an array of hashes.
      def generate_changeset(attribute, values, type, diff)
        [
          {
            attribute_name: attribute,
            previous_value: values[0],
            new_value: values[1],
            type: type
          }
        ]
      end
    end
  end
end