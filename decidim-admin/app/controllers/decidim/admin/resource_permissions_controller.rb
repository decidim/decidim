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
        @permissions_form = PermissionsForm.from_params(params).with_context(current_organization:)

        UpdateResourcePermissions.call(@permissions_form, resource) do
          on(:ok) do
            flash[:notice] = t("resource_permissions.update.success", scope: "decidim.admin")
            redirect_to return_path
          end

          on(:invalid) do
            render action: :edit
          end
        end
      end

      private

      def return_path
        ResourceLocatorPresenter.new(resource).admin_index
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
            authorization_handlers: authorizations_for(action).keys,
            authorization_handlers_options: options_for(action)
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
          current_organization.available_authorizations - authorizations_for(action).keys
        )
      end

      def resource
        return if params[:resource_name].blank?

        resource_id = params["#{params[:resource_name]}_id"]
        resource_slug = params["#{params[:resource_name]}_slug"]

        find_by = resource_slug.present? ? { slug: resource_slug } : { id: resource_id }
        @resource ||= Decidim.find_resource_manifest(params[:resource_name])&.model_class&.find_by(find_by)
        @resource if @resource&.allow_resource_permissions?
      end

      def manifest_name
        @manifest_name ||= resource.manifest.name
      end

      def permissions
        @permissions ||= (resource&.permissions || {})
      end

      def authorizations_for(action)
        if permissions.dig(action, "authorization_handler_name")
          opts = permissions.dig(action, "options")
          { permissions.dig(action, "authorization_handler_name") => opts.blank? ? {} : { "options" => opts } }
        else
          permissions.dig(action, "authorization_handlers") || {}
        end
      end

      def options_for(action)
        authorizations_for(action)&.transform_values { |value| value["options"] }&.reject { |_, value| value.blank? }
      end
    end
  end
end
