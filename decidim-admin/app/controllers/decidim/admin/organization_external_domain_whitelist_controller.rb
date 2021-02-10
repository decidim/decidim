# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_model(current_organization.external_domain_whitelist)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_params(params)

        UpdateExternalDomainWhitelist.call(@form) do
          on(:ok) do
            redirect_to edit_organization_external_domain_whitelist_path
          end
          on(:invalid) do
            redirect_to edit_organization_external_domain_whitelist_path
          end
        end
      end
    end
  end
end
