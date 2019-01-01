# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing resource permissions.
    #
    class ResourcePermissionsController < Decidim::Admin::ApplicationController
      helper Decidim::ResourceHelper

      helper_method :authorizations, :other_authorizations_for, :resource_params, :resource

      def edit
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )
      end

      def update
        @permissions_form = PermissionsForm.from_params(params)

        UpdateResourcePermissions.call(@permissions_form, resource) do
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
        send("#{resource_symbol.to_s.pluralize}_path")
      end

      def resource_params
        params.permit(:resource_id, :resource_name).to_h.symbolize_keys
      end

      def resource_symbol
        @resource_symbol ||= resource.class.name.demodulize.underscore.to_sym
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
        @actions ||= resource&.resource_manifest&.actions
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
        @resource ||= if (res_name = params[:resource_name])
                        res = Decidim.find_resource_manifest(res_name)&.model_class&.find_by(id: params["#{res_name}_id"])
                        res if res&.allow_resource_permissions?
                      end
      end

      def permissions
        @permissions ||= (resource&.permissions || {})
      end

      def authorization_for(action)
        permissions.dig(action, "authorization_handler_name")
      end
    end
  end
end
