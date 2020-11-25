# frozen_string_literal: true

module Decidim
  class ParticipatorySpaceResources < Rectify::Query
    def self.for(participatory_space)
      new(participatory_space).query
    end

    def initialize(participatory_space)
      @participatory_space = participatory_space
    end

    def query
      @participatory_space.components.flat_map do |component|
        klass = manifest_name_to_class(component.manifest_name)

        next if klass.blank?
        next unless klass.column_names.include? "decidim_component_id"

        klass.where(component: component)
      end.compact
    end

    private

    def manifest_name_to_class(name)
      resource_registry = Decidim.resource_registry.find(name)
      return if resource_registry.blank?

      resource_registry.model_class_name&.safe_constantize
    end
  end
end
