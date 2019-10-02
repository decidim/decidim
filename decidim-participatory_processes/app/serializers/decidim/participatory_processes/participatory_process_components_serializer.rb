# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class serializes a ParticipatoryProcesses so can be exported to CSV, JSON or other
    # formats.
    class ParticipatoryProcessComponentsSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a participatory_process.
      def initialize(participatory_process)
        @participatory_process = participatory_process
      end

      # Public: Exports a hash with the serialized data for this participatory_process.
      def serialize
        response= []
        participatory_process.components.each do |component|
          serialized = {
            component_class: component.class.name,
            manifest_name: component.manifest_name,
            name: component.name,
            participatory_space_id: component.participatory_space_id,
            participatory_space_type: component.participatory_space_type,
            settings: serialize_settings(component),
            weight: component.weight,
            permissions: component.permissions,
          }
          fill_component_specific_fields(serialized) if has_component_specific_fields?(component)
          response << serialized
        end
        response
      end

      private

      attr_reader :participatory_process

      def has_component_specific_fields?(component)
        component.manifest.serializes_specific_fields?
      end
    end
  end
end
