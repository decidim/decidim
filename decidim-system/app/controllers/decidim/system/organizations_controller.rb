# frozen_string_literal: true
require_dependency "decidim/system/application_controller"

module Decidim
  module System
    # Controller to manage Organizations (tenants).
    #
    class OrganizationsController < ApplicationController
      def new
        @form = OrganizationForm.new
      end

      def create
        @form = OrganizationForm.from_params(params)

        RegisterOrganization.call(@form) do
          on(:ok) do
            flash[:notice] = "Organization created successfully."
            redirect_to organizations_path
          end

          on(:invalid) do
            flash[:alert] = "There was an error when creating a new organization."
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
    end
  end
end
