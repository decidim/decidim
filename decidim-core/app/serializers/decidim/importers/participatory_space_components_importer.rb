# frozen_string_literal: true

module Decidim
  module Importers
    # This class parses and imports all components in a ParticipatorySpace.
    # It currently supports JSON format.
    class ParticipatorySpaceComponentsImporter
      # Parses an exported list of components and imports them into the
      # platform.
      #
      # +participatory_space+: The ParticipatorySpace to which all components
      # will belong to.
      # +json_text+: A json document as a String.
      # +user+: The Decidim::User that is importing.
      def from_json(participatory_space, json_text, user)
        json = JSON.parse(json_text)
        import(participatory_space, json, user)
      end

      # For each component configuration in the json,
      # creates a new Decidim::Component with that configuration.
      #
      # Returns: An Array with all components created.
      #
      # +participatory_space+: The ParticipatorySpace to which all components
      # will belong to.
      # +json+: An array of json compatible Hashes with the configuration of Decidim::Components.
      # +user+: The Decidim::User that is importing.
      def import(participatory_space, json_ary, user)
        json_ary.collect do |serialized|
          attributes = serialized.with_indifferent_access
          # we override the parent participatory sapce
          attributes["participatory_space_id"] = participatory_space.id
          attributes["participatory_space_type"] = participatory_space.class.name
          result = Decidim.traceability.perform_action!(:create,
                                                        Decidim::Component,
                                                        user) { Decidim::Component.create!(attributes.except(:id)) }
          result
        end
      end
    end
  end
end
