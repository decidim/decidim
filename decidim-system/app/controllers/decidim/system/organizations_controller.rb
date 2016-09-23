# frozen_string_literal: true
require_dependency "decidim/system/application_controller"

module Decidim
  module System
    # Controller to manage Organizations (tenants).
    #
    class OrganizationsController < ApplicationController
      def new
        @form = RegisterOrganizationForm.new
      end

      def create
        @form = RegisterOrganizationForm.from_params(params)

        RegisterOrganization.call(@form) do
          on(:ok) do
            flash[:notice] = t("decidim.system.commands.register_organization.ok")
            redirect_to organizations_path
          end

          on(:invalid) do
            flash.now[:alert] = t("decidim.system.commands.register_organization.invalid")
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
        @form = UpdateOrganizationForm.from_model(organization)
      end

      def update
        @form = UpdateOrganizationForm.from_params(params)

        UpdateOrganization.call(params[:id], @form) do
          on(:ok) do
            flash[:notice] = t("decidim.system.commands.update_organization.ok")
            redirect_to organizations_path
          end

          on(:invalid) do
            flash.now[:alert] = t("decidim.system.commands.update_organization.invalid")
            render :edit
          end
        end
      end
    end
  end
end
