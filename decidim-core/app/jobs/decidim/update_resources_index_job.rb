# frozen_string_literal: true

module Decidim
  class UpdateResourcesIndexJob < ApplicationJob
    queue_as :default

    def perform(parent)
      return if parent.components.empty?

      components_hash = parent.components.map do |component|
        {
          manifest: Decidim.find_component_manifest(component.manifest_name),
          id: component.id
        }
      end

      resources = components_hash.flat_map do |component_hash|
        Decidim.resource_registry.manifests.map do |resource|
          next unless resource.component_manifest == component_hash[:manifest]

          {
            class: resource.model_class_name,
            id: component_hash[:id]
          }
        end.compact
      end

      descendants = resources.flat_map do |resource|
        klass = resource[:class].constantize

        next unless klass.column_names.include? "decidim_component_id"

        klass.where(decidim_component_id: resource[:id])
      end.compact

      descendants.each(&:try_update_index_for_search_resource)
    end
  end
end
