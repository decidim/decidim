# frozen_string_literal: true

module Decidim
  module System
    # Controller to manage Organizations (tenants).
    #
    class OrganizationsController < Decidim::System::ApplicationController
      helper_method :current_organization, :provider_enabled?
      helper Decidim::OmniauthHelper

      def new
        @form = form(RegisterOrganizationForm).from_params(default_params)
        @form.file_upload_settings = form(FileUploadSettingsForm).from_model({})
      end

      def create
        @form = form(RegisterOrganizationForm).from_params(params)

        CreateOrganization.call(@form) do
          on(:ok) do
            flash[:notice] = t("organizations.create.success_html", scope: "decidim.system", host: @form.host, email: @form.organization_admin_email)
            redirect_to organizations_path
          end

          on(:invalid_invitation) do
            flash.now[:alert] = t("organizations.create.error_invitation", scope: "decidim.system")
            render :new
          end

          on(:invalid) do
            flash.now[:alert] = t("organizations.create.error", scope: "decidim.system")
            render :new
          end
        end
      end

      def index
        @organizations = Organization.all
      end

      def edit
        @organization = Organization.find(params[:id])
        @form = form(UpdateOrganizationForm).from_model(@organization)
      end

      def update
        @organization = Organization.find(params[:id])
        @form = form(UpdateOrganizationForm).from_params(params)

        UpdateOrganization.call(params[:id], @form) do
          on(:ok) do
            flash[:notice] = t("organizations.update.success", scope: "decidim.system")
            redirect_to organizations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organizations.update.error", scope: "decidim.system")
            render :edit
          end
        end
      end

      def resend_invitation
        organization = Organization.find(params[:id])
        InviteUserAgain.call(organization.users.first, "invite_admin") do
          on(:ok) do
            flash[:notice] = t("organizations.resend_invitation.success", scope: "decidim.system")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("organizations.resend_invitation.error", scope: "decidim.system")
          end
        end

        redirect_to organizations_path
      end

      private

      def default_params
        {
          host: request.host,
          organization_admin_name: current_admin.email.split("@")[0],
          organization_admin_email: current_admin.email,
          available_locales: Decidim.available_locales.map(&:to_s),
          default_locale: Decidim.default_locale,
          users_registration_mode: "enabled"
        }
      end

      # The current organization for the request.
      #
      # Returns an Organization.
      def current_organization
        @organization
      end

      def provider_enabled?(provider)
        Decidim.omniauth_providers.dig(provider, :enabled)
      end
    end
  end
end
