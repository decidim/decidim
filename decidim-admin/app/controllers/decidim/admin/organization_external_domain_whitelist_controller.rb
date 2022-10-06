# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :blank_external_domain

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_params(params)

        UpdateExternalDomainWhitelist.call(@form, current_organization, current_user) do
          on(:ok) do
            flash[:notice] = t("domain_whitelist.update.success", scope: "decidim.admin")
            redirect_to edit_organization_external_domain_whitelist_path
          end
          on(:invalid) do
            flash[:notice] = t("domain_whitelist.update.error", scope: "decidim.admin")
            render action: "edit"
          end
        end
      end

      private

      def blank_external_domain
        @blank_external_domain ||= Admin::ExternalDomainForm.new
      end
    end
  end
end
