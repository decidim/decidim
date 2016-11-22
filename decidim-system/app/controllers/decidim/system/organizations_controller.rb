# frozen_string_literal: true
require_dependency "decidim/system/application_controller"

module Decidim
  module System
    # Controller to manage Organizations (tenants).
    #
    class OrganizationsController < ApplicationController
      def new
        @form = form(RegisterOrganizationForm).instance
      end

      def create
        @form = form(RegisterOrganizationForm).from_params(params)

        RegisterOrganization.call(@form) do
          on(:ok) do
            flash[:notice] = t("organizations.create.success", scope: "decidim.system")
            redirect_to organizations_path
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

      def show
        @organization = Organization.find(params[:id])
      end

      def edit
        organization = Organization.find(params[:id])
        @form = form(UpdateOrganizationForm).from_model(organization)
      end

      def update
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
    end
  end
end
