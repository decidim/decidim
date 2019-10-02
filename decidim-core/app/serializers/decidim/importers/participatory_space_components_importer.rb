# frozen_string_literal: true

module Decidim
  module Importers
    # This class parses and imports all components in a ParticipatorySpace.
    # It currently supports JSON format.
    module ParticipatorySpaceComponentsImporter

      # Parses an exported list of components and imports them into the
      # platform.
      #
      # +json_text+: A json document as a String.
      def from_json(json_text)
        json= JSON.parse(json_text)
        import(json)
      end
      module_function :from_json

      # For each component configuration in the json,
      # creates a new Decidim::Component with that configuration.
      # 
      # Returns: An Array with all components created.
      # 
      # +json+: An array of json compatible Hashes with the configuration of Decidim::Components.
      def import(json_ary)
        json_ary.collect do |serialized|
          attributes= serialized
          Decidim.traceability.perform_action!(
            "create",
            Decidim::Component,
            attributes
          )
        end
      end
      module_function :import
    end
  end
end