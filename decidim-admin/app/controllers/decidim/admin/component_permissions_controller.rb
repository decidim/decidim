# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing component and related resources permissions.
    #
    class ComponentPermissionsController < ResourcePermissionsController
      include Decidim::ComponentPathHelper

      def edit
        enforce_permission_to :update, :component, component: component
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )

        render template: "decidim/admin/resource_permissions/edit"
      end

      def update
        enforce_permission_to :update, :component, component: component
        @permissions_form = PermissionsForm.from_params(params)

        UpdateComponentPermissions.call(@permissions_form, component, resource, current_user) do
          on(:ok) do
            flash[:notice] = t("component_permissions.update.success", scope: "decidim.admin")
            redirect_to return_path
          end

          on(:invalid) do
            flash.now[:alert] = t("component_permissions.update.error", scope: "decidim.admin")
            render action: :edit
          end
        end
      end

      private

      def return_path
        if resource
          manage_component_path(component)
        else
          components_path(current_participatory_space)
        end
      end

      def actions
        @actions ||= (resource&.resource_manifest || component.manifest).actions
      end

      def resource
        @resource ||= if params[:resource_id] && params[:resource_name]
                        res = Decidim.find_resource_manifest(params[:resource_name])&.resource_scope(component)&.find_by(id: params[:resource_id])
                        res if res&.allow_resource_permissions?
                      end
      end

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end

      def permissions
        @permissions ||= (component.permissions || {}).merge(resource&.permissions || {})
      end
    end
  end
end
