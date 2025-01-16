# frozen_string_literal: true

module Decidim
  module Admin
    # Concern to handle warnings for deleted (trashed) resources
    #
    # # i18n-tasks-use t('decidim.admin.trash_management.restore.invalid')
    # # i18n-tasks-use t('decidim.admin.trash_management.restore.success')
    # # i18n-tasks-use t('decidim.admin.trash_management.soft_delete.invalid')
    # # i18n-tasks-use t('decidim.admin.trash_management.soft_delete.success')
    module HasTrashableResources
      extend ActiveSupport::Concern

      included do
        helper_method :trashable_deleted_collection

        before_action :trashable_set_deleted_warning, if: :trash_zone?

        # i18n-tasks-use t('decidim.admin.trash_management.soft_delete.invalid')
        # i18n-tasks-use t('decidim.admin.trash_management.soft_delete.success')
        def soft_delete
          enforce_permission_to(:soft_delete, trashable_deleted_resource_type, trashable_deleted_resource:)

          Decidim::Commands::SoftDeleteResource.call(trashable_deleted_resource, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("soft_delete.success", scope: trashable_i18n_scope, resource_name: human_readable_resource_name.capitalize)
              redirect_to_resource_index
            end

            on(:invalid) do
              flash[:alert] = I18n.t("soft_delete.invalid", scope: trashable_i18n_scope, resource_name: human_readable_resource_name)
              redirect_to_resource_index
            end
          end
        end

        # i18n-tasks-use t('decidim.admin.trash_management.restore.invalid')
        # i18n-tasks-use t('decidim.admin.trash_management.restore.success')
        def restore
          enforce_permission_to(:restore, trashable_deleted_resource_type, trashable_deleted_resource:)

          Decidim::Commands::RestoreResource.call(trashable_deleted_resource, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("restore.success", scope: trashable_i18n_scope, resource_name: human_readable_resource_name.capitalize)
              redirect_to_resource_trash
            end

            on(:invalid) do
              flash[:alert] = I18n.t("restore.invalid", scope: trashable_i18n_scope, resource_name: human_readable_resource_name)
              redirect_to_resource_trash
            end
          end
        end

        def manage_trash
          enforce_permission_to :manage_trash, trashable_deleted_resource_type
        end
      end

      private

      def trashable_deleted_resource_type
        raise NotImplementedError, "Return the type of the deleted resource (symbol)"
      end

      def trashable_deleted_resource
        raise NotImplementedError, "Return the deleted resource or nil"
      end

      def trashable_deleted_collection
        raise NotImplementedError, "Return the collection of deleted resources"
      end

      # override to customize flash messages
      def trashable_i18n_scope
        "decidim.admin.trash_management"
      end

      def find_parent_resource
        respond_to?(:parent_resource_finder, true) ? find_parent_resource : nil
      end

      # defaults to the resource name pluralized, but you can override on complex cases
      def redirect_to_resource_index
        redirect_to build_redirect_path
      end

      def redirect_to_resource_trash
        redirect_to build_redirect_path(trash: true)
      end

      def trashable_set_deleted_warning
        flash.now[:warning] = I18n.t("deleted_warning", scope: trashable_i18n_scope, default: t("decidim.admin.manage_trash.deleted_items_warning"))
      end

      def build_redirect_path(trash: false)
        parent_resource = find_parent_resource

        if parent_resource.present?
          parent_resource_name = parent_resource.class.name.demodulize.underscore
          action_prefix = trash ? "manage_trash_" : ""
          route_name = "#{action_prefix}#{parent_resource_name}_#{trashable_deleted_resource_type.to_s.pluralize}_path"
          if respond_to?(:current_component)
            Decidim::EngineRouter.admin_proxy(current_component).send(route_name, parent_resource)
          else
            send(route_name, parent_resource)
          end
        else
          action_prefix = trash ? "manage_trash_" : ""
          route_name = "#{action_prefix}#{trashable_deleted_resource_type.to_s.pluralize}_path"
          if respond_to?(:current_component)
            Decidim::EngineRouter.admin_proxy(current_component).send(route_name)
          else
            send(route_name)
          end
        end
      end

      def trash_zone?
        case action_name
        when "manage_trash"
          true
        when "index", "show", "new", "edit"
          resource_or_parents_trashed?
        else
          false
        end
      end

      def parent_resource
        trashable_deleted_resource&.try(:parent)
      end

      def component_trashed?
        respond_to?(:current_component) && current_component&.deleted?
      end

      def participatory_space_trashed?
        current_participatory_space.respond_to?(:deleted?) && current_participatory_space&.deleted?
      end

      def resource_trashed?
        trashable_deleted_resource&.deleted?
      end

      def parent_trashed?
        parent_resource&.deleted?
      end

      def parent_id_trashed?
        parent_resource = find_parent_resource
        parent_resource&.deleted? || false
      end

      def human_readable_resource_name
        trashable_deleted_resource_type.to_s.humanize
      end

      def resource_or_parents_trashed?
        return true if component_trashed?
        return true if participatory_space_trashed?
        return true if resource_trashed?
        return true if parent_trashed?
        return true if parent_id_trashed?

        false
      end
    end
  end
end
