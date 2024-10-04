# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainAllowlistController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :blank_external_domain

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainAllowlistForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainAllowlistForm).from_params(params)

        UpdateExternalDomainAllowlist.call(@form, current_organization) do
          on(:ok) do
            flash[:notice] = t("domain_allowlist.update.success", scope: "decidim.admin")
            redirect_to edit_organization_external_domain_allowlist_path
          end
          on(:invalid) do
            flash[:notice] = t("domain_allowlist.update.error", scope: "decidim.admin")
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
