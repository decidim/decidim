# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class OrganizationController < ApplicationController
      layout "decidim/admin/settings"

      def edit
        authorize! :update, current_organization
        @form = form(OrganizationForm).from_model(current_organization)
      end

      def update
        authorize! :update, current_organization
        @form = form(OrganizationForm).from_params(form_params)

        UpdateOrganization.call(current_organization, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("organization.update.success", scope: "decidim.admin")
            redirect_to edit_organization_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organization.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      private

      def form_params
        params[:organization] ||= {}
        params[:organization][:id] ||= current_organization.id
        params
      end
    end
  end
end
