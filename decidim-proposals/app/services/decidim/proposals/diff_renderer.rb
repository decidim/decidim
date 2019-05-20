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
            parse_changeset(attribute, values, type, diff)
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
            old_value: emendation_value_for(attribute) || values[0],
            new_value: values[1]
          }
        )
      end

      # Retrieves the attribute value of the amended proposal.
      # Returns the last version if the amendment is being evaluated; else,
      # returns the original version at the moment of creating the amendment.
      def emendation_value_for(attribute)
        return unless proposal.emendation?
        return last_version(attribute) if proposal.amendment.evaluating?

        original_version(attribute)
      end

      # Retrieves the CURRENT attribute value of the amended proposal.
      def last_version(attribute)
        proposal.amendable.attributes[attribute.to_s]
      end

      # Retrieves the attribute value of the amended proposal STORED in the first
      # version created in Decidim::Amendable::Create.create_emendation!
      def original_version(attribute)
        proposal.versions.first.changeset[attribute.to_s].last
      end

      def proposal
        @proposal ||= Proposal.find(version.item_id)
      end
    end
  end
end
