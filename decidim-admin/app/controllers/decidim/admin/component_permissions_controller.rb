# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing component permissions.
    #
    class ComponentPermissionsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      helper Decidim::ResourceHelper

      helper_method :authorizations, :other_authorizations_for, :component, :resource_params, :resource

      def edit
        enforce_permission_to :update, :component, component: component
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )
      end

      def update
        enforce_permission_to :update, :component, component: component
        @permissions_form = PermissionsForm.from_params(params)

        UpdateComponentPermissions.call(@permissions_form, component, resource) do
          on(:ok) do
            flash[:notice] = t("component_permissions.update.success", scope: "decidim.admin")
            redirect_to return_path
          end

          on(:invalid) do
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

      def resource_params
        params.permit(:resource_id, :resource_name).to_h.symbolize_keys
      end

      def permission_forms
        actions.inject({}) do |result, action|
          form = PermissionForm.new(
            authorization_handler_name: authorization_for(action),
            options: permissions.dig(action, "options")
          )

          result.update(action => form)
        end
      end

      def actions
        @actions ||= (resource&.resource_manifest || component.manifest).actions
      end

      def authorizations
        Verifications::Adapter.from_collection(
          current_organization.available_authorizations
        )
      end

      def other_authorizations_for(action)
        Verifications::Adapter.from_collection(
          current_organization.available_authorizations - [authorization_for(action)]
        )
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

      def authorization_for(action)
        permissions.dig(action, "authorization_handler_name")
      end
    end
  end
end
