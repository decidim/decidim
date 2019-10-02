# frozen_string_literal: true

module Decidim
  module Exporters
    # This class serializes all components in a ParticipatorySpace so can be
    # exported to CSV, JSON or other formats.
    class ParticipatorySpaceComponentsSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a participatory_space.
      def initialize(participatory_space)
        @participatory_space = participatory_space
      end

      # Public: Exports a hash with the serialized data for this participatory_space.
      def serialize
        participatory_space.components.collect do |component|
          serialized = {
            component_class: component.class.name,
            manifest_name: component.manifest_name,
            id: component.id,
            name: component.name,
            participatory_space_id: component.participatory_space_id,
            participatory_space_type: component.participatory_space_type,
            settings: component.settings.to_json,
            weight: component.weight,
            permissions: component.permissions
          }
          fill_component_specific_data(component, serialized) if has_component_specific_data?(component)
          serialized
        end
      end

      private

      attr_reader :participatory_space

      def has_component_specific_data?(component)
        component.manifest.serializes_specific_data?
      end

      def fill_component_specific_data(component, serialized)
        serialized[:specific_data] = component.serialize_specific_data
      end
    end
  end
end
