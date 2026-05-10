# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class OrganizationController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper Decidim::Admin::UploaderImageDimensionsHelper

      add_breadcrumb_item_from_menu :admin_settings_menu

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_params(params)
        @form.id = current_organization.id

        UpdateOrganization.call(@form, current_organization) do
          on(:ok) do
            flash[:notice] = I18n.t("organization.update.success", scope: "decidim.admin")
            redirect_to edit_organization_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organization.update.error", scope: "decidim.admin")
            render :edit, status: :unprocessable_content
          end
        end
      end
    end
  end
end
