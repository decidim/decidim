# frozen_string_literal: true

module Decidim
  module Importers
    # This class parses and imports all components in a ParticipatorySpace.
    # It currently supports JSON format.
    class ParticipatorySpaceComponentsImporter < Decidim::Importers::Importer
      # +participatory_space+: The ParticipatorySpace to which all components
      # will belong to.
      def initialize(participatory_space)
        @participatory_space = participatory_space
      end

      # Parses an exported list of components and imports them into the
      # platform.
      #
      # +participatory_space+: The ParticipatorySpace to which all components
      # will belong to.
      # +json_text+: A json document as a String.
      # +user+: The Decidim::User that is importing.
      def from_json(json_text, user)
        json = JSON.parse(json_text)
        import(json, user)
      end

      # For each component configuration in the json,
      # creates a new Decidim::Component with that configuration.
      #
      # Returns: An Array with all components created.
      #
      # +json+: An array of json compatible Hashes with the configuration of Decidim::Components.
      # +user+: The Decidim::User that is importing.
      def import(json_ary, user)
        ActiveRecord::Base.transaction do
          json_ary.collect do |serialized|
            attributes = serialized.with_indifferent_access
            # we override the parent participatory sapce
            attributes["participatory_space_id"] = @participatory_space.id
            attributes["participatory_space_type"] = @participatory_space.class.name
            import_component_from_attributes(attributes, user)
          end
        end
      end

      private

      # Returns a persisted Component instance build from the +attributes+ argument.
      def import_component_from_attributes(attributes, user)
        component = Decidim.traceability.perform_action!(:create,
                                                         Decidim::Component,
                                                         user) do
          c = Decidim::Component.new(attributes.except(:id, :settings, :specific_data))
          c[:settings] = attributes[:settings]
          c.save!
          c
        end
        import_component_specific_data(component, attributes, user) if component.serializes_specific_data?
        component
      end

      def import_component_specific_data(component, serialized, user)
        specific_importer = component.manifest.specific_data_importer_class.new(component)
        specific_importer.import(serialized[:specific_data], user)
      end
    end
  end
end
