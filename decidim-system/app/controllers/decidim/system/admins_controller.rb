# frozen_string_literal: true
require_dependency "decidim/system/application_controller"

module Decidim
  module System
    # Controller that allows managing all the Admins.
    #
    class AdminsController < ApplicationController
      def index
        @admins = Admin.all
      end

      def new
        @form = AdminForm.new
      end

      def create
        @form = AdminForm.from_params(params)

        CreateAdmin.call(@form) do
          on(:ok) do
            flash[:notice] = "Admin created successfully."
            redirect_to admins_path
          end

          on(:invalid) do
            flash[:alert] = "There was an error when creating a new admin."
            render :new
          end
        end
      end

      def edit
        @admin = Admin.find(params[:id])
        @form = AdminForm.from_model(@admin)
      end

      def update
        @admin = Admin.find(params[:id])
        @form = AdminForm.from_params(params)

        UpdateAdmin.call(@admin, @form) do
          on(:ok) do
            flash[:notice] = "Admin updated successfully."
            redirect_to admins_path
          end

          on(:invalid) do
            flash[:alert] = "There was an error when updating this admin."
            render :new
          end
        end
      end

      def show
        @admin = Admin.find(params[:id])
      end

      def destroy
        @admin = Admin.find(params[:id]).destroy!
        flash[:notice] = "Admin successfully destroyed"

        redirect_to admins_path
      end
    end
  end
end
