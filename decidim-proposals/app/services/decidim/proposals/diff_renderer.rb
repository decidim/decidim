# frozen_string_literal: true

module Decidim
  module Proposals
    class DiffRenderer
      def initialize(version)
        @version = version
      end

      # Renders the diff of the given changeset. Doesn't take into account translatable fields.
      #
      # Returns a Hash, where keys are the fields that have changed and values are an
      # array, the first element being the previous value and the last being the new one.
      def diff
        version.changeset.inject({}) do |diff, (attribute, values)|
          attribute = attribute.to_sym
          type = attribute_types[attribute]

          if type.blank?
            diff
          else
            parse_changeset(attribute, parse_values(attribute, values), type, diff)
          end
        end
      end

      private

      attr_reader :version

      # Lists which attributes will be diffable and how
      # they should be rendered.
      def attribute_types
        {
          title: :string,
          body: :string,
          decidim_category_id: :category,
          decidim_scope_id: :scope,
          address: :string,
          latitude: :string,
          longitude: :string,
          state: :string
        }
      end

      def parse_changeset(attribute, values, type, diff)
        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: "activemodel.attributes.collaborative_draft"),
            old_value: values[0],
            new_value: values[1]
          }
        )
      end

      # Handles which values to use when diffing emendations and
      # normalizes line endings of the :body attribute values.
      # Returns and Array of two Strings.
      def parse_values(attribute, values)
        values = [amended_previous_value(attribute), values[1]] if proposal&.emendation?
        values = values.map { |value| normalize_line_endings(value) } if attribute == :body
        values
      end

      # Sets the previous value so the emendation can be compared with the amended proposal.
      # If the amendment is being evaluated, returns the CURRENT attribute value of the amended proposal;
      # else, returns the attribute value of amended proposal at the moment of making the amendment.
      def amended_previous_value(attribute)
        if proposal.amendment.evaluating?
          proposal.amendable.attributes[attribute.to_s]
        else # See Decidim::Amendable::PublishDraft#set_first_emendation_version
          proposal.versions.first.changeset[attribute.to_s].last
        end
      end

      # Returns a String with the newline escape sequences normalized.
      def normalize_line_endings(string)
        Decidim::ContentParsers::NewlineParser.new(string, context: {}).rewrite
      end

      def proposal
        @proposal ||= Proposal.find_by(id: version.item_id)
      end
    end
  end
end
