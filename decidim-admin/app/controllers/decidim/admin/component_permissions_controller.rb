# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing component permissions.
    #
    class ComponentPermissionsController < Decidim::Admin::ApplicationController
      helper_method :authorizations, :component

      def edit
        authorize! :update, component
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )
      end

      def update
        authorize! :update, component
        @permissions_form = PermissionsForm.from_params(params)

        UpdateComponentPermissions.call(@permissions_form, component) do
          on(:ok) do
            flash[:notice] = t("component_permissions.update.success", scope: "decidim.admin")
            redirect_to components_path(current_participatory_space)
          end

          on(:invalid) do
            render action: :edit
          end
        end
      end

      private

      def permission_forms
        permissions = component.permissions || {}

        @permission_forms ||= component.manifest.actions.inject({}) do |result, action|
          form = PermissionForm.new(
            authorization_handler_name: permissions.dig(action, "authorization_handler_name"),
            options: permissions.dig(action, "options").try(:to_json)
          )

          result.update(action => form)
        end
      end

      def authorizations
        Verifications::Adapter.from_collection(
          current_organization.available_authorizations
        )
      end

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
