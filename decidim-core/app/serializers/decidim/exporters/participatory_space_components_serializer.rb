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
            manifest_name: component.manifest_name,
            id: component.id,
            name: component.name,
            participatory_space_id: component.participatory_space_id,
            participatory_space_type: component.participatory_space_type,
            settings: component[:settings].as_json,
            weight: component.weight,
            permissions: component.permissions,
            published_at: component.published_at
          }
          serialized[:specific_data] = serialize_component_specific_data(component) if component.serializes_specific_data?
          serialized
        end
      end

      private

      attr_reader :participatory_space

      def serialize_component_specific_data(component)
        specific_serializer = component.manifest.specific_data_serializer_class.new(component)
        specific_serializer.serialize
      end
    end
  end
end
