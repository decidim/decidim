# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class FeaturePermissionsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin
      helper_method :authorizations, :feature

      def edit
        authorize! :update, feature
        @permissions_form = PermissionsForm.new(
          permissions: permission_forms
        )
      end

      def update
        authorize! :update, feature
        @permissions_form = PermissionsForm.from_params(params)

        if @permissions_form.valid?
          permissions = @permissions_form.permissions.inject({}) do |result, (key, value)|
            serialized = {
              "authorization_handler_name" => value.authorization_handler_name
            }

            serialized["options"] = JSON.parse(value.options) if value.options
            result.update(key => serialized)
          end

          feature.update_attributes!(
            permissions: permissions
          )

          flash[:notice] = t("feature_permissions.update.success", scope: "decidim.admin")
          redirect_to participatory_process_features_path(participatory_process)
        else
          render action: :edit
        end
      end

      private

      def permission_forms
        permissions = feature.permissions || {}

        @permission_forms ||= feature.manifest.actions.inject({}) do |result, action|
          form = PermissionForm.new(
            authorization_handler_name: permissions.dig(action, "authorization_handler_name"),
            options: permissions.dig(action, "options").try(:to_json)
          )

          result.update(action => form)
        end
      end

      def authorizations
        Decidim.authorization_handlers.map(&:handler_name)
      end

      def feature
        @feature ||= participatory_process.features.find(params[:feature_id])
      end
    end
  end
end
