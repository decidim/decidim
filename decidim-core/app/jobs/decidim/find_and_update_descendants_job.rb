# frozen_string_literal: true

module Decidim
  class FindAndUpdateDescendantsJob < ApplicationJob
    queue_as :default

    def perform(element)
      descendants_collector = []

      descendants_collector << comments if element.respond_to?(:comments)

      if element.respond_to?(:components)
        element.components.each do |component|
          klass = component.manifest_name == "blogs" ? Decidim::Blogs::Post : manifest_name_to_class(component.manifest_name)
          next if klass.blank?
          next unless klass.column_names.include? "decidim_component_id"

          descendants_collector << klass.where(component: component).to_a
        end
      end

      descendants_collector.each { |descendants| Decidim::UpdateSearchIndexesJob.perform_later(descendants) }
    end

    private

    def manifest_name_to_class(name)
      resource_registry = Decidim.resource_registry.find(name)
      return if resource_registry.blank?

      resource_registry.model_class_name&.safe_constantize
    end
  end
end
