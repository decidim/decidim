# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the appearance of the organization.
    class OrganizationAppearanceController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def edit
        authorize! :update, current_organization
        @form = form(OrganizationAppearanceForm).from_model(current_organization)
      end

      def update
        authorize! :update, current_organization
        @form = form(OrganizationAppearanceForm).from_params(params)

        UpdateOrganizationAppearance.call(current_organization, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("organization.update.success", scope: "decidim.admin")
            redirect_to edit_organization_appearance_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organization.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end
    end
  end
end
