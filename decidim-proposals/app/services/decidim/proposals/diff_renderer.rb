# frozen_string_literal: true

module Decidim
  module Proposals
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :i18n,
          body: :i18n,
          decidim_category_id: :category,
          decidim_scope_id: :scope,
          address: :string,
          latitude: :string,
          longitude: :string,
          decidim_proposals_proposal_state_id: :state
        }
      end

      # Parses the values before parsing the changeset.
      def parse_changeset(attribute, values, type, diff)
        return parse_i18n_changeset(attribute, values, type, diff) if [:i18n, :i18n_html].include?(type)
        return parse_scope_changeset(attribute, values, type, diff) if type == :scope
        return parse_state_changeset(attribute, values, type, diff) if type == :state

        values = parse_values(attribute, values)
        old_value = values[0]
        new_value = values[1]

        diff.update(
          attribute => {
            type:,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value:,
            new_value:
          }
        )
      end

      def parse_state_changeset(attribute, values, type, diff)
        return unless diff

        old_scope = Decidim::Proposals::ProposalState.find_by(id: values[0])
        new_scope = Decidim::Proposals::ProposalState.find_by(id: values[1])

        diff.update(
          attribute => {
            type:,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_scope ? translated_attribute(old_scope.title) : "",
            new_value: new_scope ? translated_attribute(new_scope.title) : ""
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
      def normalize_line_endings(value)
        if value.is_a?(Hash)
          value.values.map { |subvalue| normalize_line_endings(subvalue) }
        else
          Decidim::ContentParsers::NewlineParser.new(value, context: {}).rewrite
        end
      end

      def proposal
        @proposal ||= Proposal.find_by(id: version.item_id)
      end
    end
  end
end
