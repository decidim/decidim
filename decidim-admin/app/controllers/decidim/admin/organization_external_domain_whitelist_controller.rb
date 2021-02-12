# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :blank_external_url

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationExternalDomainWhitelistForm).from_params(params)

        UpdateExternalDomainWhitelist.call(@form) do
          on(:ok) do
            render :edit
          end
          on(:invalid) do
            render :edit
          end
        end
      end

      private

      def blank_external_url
        @blank_external_url ||= Admin::ExternalDomainForm.new
      end
    end
  end
end
