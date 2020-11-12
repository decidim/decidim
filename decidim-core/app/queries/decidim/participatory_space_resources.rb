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
        klass = manifest_name_to_class(component.manifest.name.to_s)

        next unless klass.column_names.include? "decidim_component_id"

        klass.where(component: component)
      end
    end

    private

    def manifest_name_to_class(name)
      Decidim.resource_registry.find(name).model_class_name.constantize
    end
  end
end
