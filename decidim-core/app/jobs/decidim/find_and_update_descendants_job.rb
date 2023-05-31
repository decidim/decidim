# frozen_string_literal: true

module Decidim
  # Update search indexes for each descendants of a given element
  class FindAndUpdateDescendantsJob < ApplicationJob
    queue_as :default

    def perform(element)
      descendants_collector = components_for(element)
      descendants_collector << element.comments.to_a if element.respond_to?(:comments)

      return if descendants_collector.blank?

      descendants_collector.each do |descendants|
        next if descendants.blank?

        Decidim::UpdateSearchIndexesJob.perform_later(descendants)
      end
    end

    private

    def manifest_name_to_class(name)
      resource_registry = Decidim.resource_registry.find(name)
      return if resource_registry.blank?

      resource_registry.model_class_name&.safe_constantize
    end

    # returns array of components
    # If element not responds to components, returns empty array
    def components_for(element)
      return [] unless element.respond_to?(:components) && !element.components.empty?

      ary = []
      element.components.each do |component|
        klass = component.manifest_name == "blogs" ? Decidim::Blogs::Post : manifest_name_to_class(component.manifest_name)

        next if klass.blank?
        next if klass.column_names.exclude? "decidim_component_id"

        ary << klass.where(component:).to_a
      end

      ary
    end
  end
end
