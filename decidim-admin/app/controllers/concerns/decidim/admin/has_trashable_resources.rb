# frozen_string_literal: true

module Decidim
  module Admin
    # Concern to handle warnings for deleted (trashed) resources
    module HasTrashableResources
      extend ActiveSupport::Concern

      included do
        helper_method :trashable_deleted_collection

        before_action :trashable_set_deleted_warning, if: :trash_zone?

        def soft_delete
          enforce_permission_to(:soft_delete, trashable_deleted_resource_type, trashable_deleted_resource:)

          Decidim::Commands::SoftDeleteResource.call(trashable_deleted_resource, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("soft_delete.success", scope: trashable_i18n_scope)
              redirect_to_resource_index
            end

            on(:invalid) do
              flash[:alert] = I18n.t("soft_delete.invalid", scope: trashable_i18n_scope)
              redirect_to_resource_index
            end
          end
        end

        def restore
          enforce_permission_to(:restore, trashable_deleted_resource_type, trashable_deleted_resource:)

          Decidim::Commands::RestoreResource.call(trashable_deleted_resource, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("restore.success", scope: trashable_i18n_scope)
              redirect_to_resource_trash
            end

            on(:invalid) do
              flash[:alert] = I18n.t("restore.invalid", scope: trashable_i18n_scope)
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
        "decidim.admin"
      end

      def find_parent_resource
        raise NotImplementedError, "Return the parent resource based on the given parent_id"
      end

      # defaults to the resource name pluralized, but you can override on complex cases
      def redirect_to_resource_index
        redirect_to send("#{trashable_deleted_resource_type.to_s.pluralize}_path")
      end

      def redirect_to_resource_trash
        redirect_to send("manage_trash_#{trashable_deleted_resource_type.to_s.pluralize}_path")
      end

      def trashable_set_deleted_warning
        flash.now[:warning] = I18n.t("deleted_warning", scope: trashable_i18n_scope, default: t("decidim.admin.manage_trash.deleted_items_warning"))
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
        respond_to?(:current_component) && current_component&.trashed?
      end

      def participatory_space_trashed?
        respond_to?(:current_participatory_space) && current_participatory_space&.trashed?
      end

      def resource_trashed?
        trashable_deleted_resource&.trashed?
      end

      def parent_trashed?
        parent_resource&.trashed?
      end

      def parent_id_trashed?
        if params[:parent_id].present?
          parent = find_parent_resource
          return parent&.trashed?
        end
        false
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
