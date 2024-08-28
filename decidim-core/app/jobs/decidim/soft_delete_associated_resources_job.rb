# frozen_string_literal: true

module Decidim
  class SoftDeleteAssociatedResourcesJob < ApplicationJob
    queue_as :default

    def perform(object_id, object_class, user_id)
      object = object_class.constantize.find(object_id)
      current_user = Decidim::User.find(user_id)

      return if object.nil? || current_user.nil?

      trash_associated_objects(object, current_user)
    rescue StandardError => e
      Rails.logger.error("Error soft deleting associated resources: #{e.message}")
    end

    private

    def trash_associated_objects(object, user)
      associated_components = find_associated_components(object)

      associated_components.each do |component|
        Decidim.traceability.perform_action!(
          "soft_delete",
          component,
          user,
          **extra_params
        ) do
          component.trash!
        end
      end
    end

    def extra_params = {}

    def find_associated_components(object)
      if participatory_space?(object)
        object.components
      else
        []
      end
    end

    def participatory_space?(object)
      object.is_a?(Decidim::ParticipatoryProcess) ||
        object.is_a?(Decidim::Assembly) ||
        object.is_a?(Decidim::Conference)
    end

    def find_associated_objects(object)
      if participatory_space?(object)
        object.components
      elsif object.is_a?(Decidim::Component)
        object.resources
      else
        []
      end
    end

    def notify_author(associated_object)
      author = associated_object.author
      return unless author

      Decidim::Notifications.notify(
        author,
        title: I18n.t("notifications.soft_delete.title", resource_name: associated_object.name),
        body: I18n.t("notifications.soft_delete.body", resource_name: associated_object.name)
      )
    end
  end
end
