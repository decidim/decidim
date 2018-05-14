# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing component permissions.
    #
    class ComponentPermissionsController < Decidim::Admin::ApplicationController
      helper_method :authorizations, :other_authorizations_for, :component

      def edit
        enforce_permission_to :update, :component, component: component
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )
      end

      def update
        enforce_permission_to :update, :component, component: component
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
        component.manifest.actions.inject({}) do |result, action|
          form = PermissionForm.new(
            authorization_handler_name: authorization_for(action),
            options: permissions.dig(action, "options")
          )

          result.update(action => form)
        end
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

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end

      def permissions
        @permissions ||= component.permissions || {}
      end

      def authorization_for(action)
        permissions.dig(action, "authorization_handler_name")
      end
    end
  end
end
