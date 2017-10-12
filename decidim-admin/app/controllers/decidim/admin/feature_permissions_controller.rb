# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing feature permissions.
    #
    class FeaturePermissionsController < Decidim::Admin::ApplicationController
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

        UpdateFeaturePermissions.call(@permissions_form, feature) do
          on(:ok) do
            flash[:notice] = t("feature_permissions.update.success", scope: "decidim.admin")
            redirect_to features_path(current_participatory_space)
          end

          on(:invalid) do
            render action: :edit
          end
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
        Verifications::Adapter.from_collection(
          current_organization.available_authorizations
        )
      end

      def feature
        @feature ||= current_participatory_space.features.find(params[:feature_id])
      end
    end
  end
end
