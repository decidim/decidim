# frozen_string_literal: true

module Decidim
  class SoftDeleteAssociatedResourcesJob < ApplicationJob
    queue_as :default

    def perform(object_id, object_class, user_id)
      object = object_class.constantize.find_by(id: object_id)
      user = Decidim::User.find_by(id: user_id)

      return if object.nil? || user.nil?

      ActiveRecord::Base.transaction do
        if object.is_a?(Decidim::Component)
          soft_delete_component_resources(object, user)
        elsif object.respond_to?(:components)
          soft_delete_space_resources(object, user)
        else
          Rails.logger.warn("Unsupported object type for soft delete: #{object.class.name}")
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error in SoftDeleteAssociatedResourcesJob: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    private

    def soft_delete_space_resources(space, user)
      space.components.each do |component|
        trash_record(component, user)
        soft_delete_component_resources(component, user)
      end
    end

    def soft_delete_component_resources(component, user)
      component_name = component.manifest_name.classify
      resource_class_name = "Decidim::#{component_name.pluralize}::#{component_name.singularize}"

      begin
        resource_class = resource_class_name.constantize
        resource_class.where(component: component).find_each do |resource|
          trash_record(resource, user)
        end
      rescue NameError => e
        Rails.logger.warn("Could not find resource class for component: #{component.manifest_name}. Error: #{e.message}")
      end
    end

    def trash_record(record, user)
      return unless record.respond_to?(:trash!)

      Decidim.traceability.perform_action!(
        "soft_delete",
        record,
        user
      ) do
        record.trash!
      end
    end
  end
end
