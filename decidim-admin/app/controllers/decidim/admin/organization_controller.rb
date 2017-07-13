# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class OrganizationController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def edit
        authorize! :update, current_organization
        @form = form(OrganizationForm).from_model(current_organization)
      end

      def update
        authorize! :update, current_organization
        @form = form(OrganizationForm).from_params(organization_params)

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

      def organization_params
        params[:organization] ||= {}
        params[:organization][:id] ||= current_organization.id
        {
          homepage_image: current_organization.homepage_image,
          logo: current_organization.logo,
          favicon: current_organization.favicon,
          official_img_header: current_organization.official_img_header,
          official_img_footer: current_organization.official_img_footer
        }.merge(params[:organization].to_unsafe_h)
      end
    end
  end
end
