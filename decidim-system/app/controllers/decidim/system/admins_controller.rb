# frozen_string_literal: true

module Decidim
  module System
    # Controller that allows managing all the Admins.
    #
    class AdminsController < Decidim::System::ApplicationController
      def index
        @admins = Admin.all
      end

      def new
        @form = form(AdminForm).instance
      end

      def create
        @form = form(AdminForm).from_params(params)

        CreateAdmin.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("admins.create.success", scope: "decidim.system")
            redirect_to admins_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("admins.create.error", scope: "decidim.system")
            render :new
          end
        end
      end

      def edit
        @admin = Admin.find(params[:id])
        @form = form(AdminForm).from_model(@admin)
      end

      def update
        @admin = Admin.find(params[:id])
        @form = form(AdminForm).from_params(params)

        UpdateAdmin.call(@admin, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("admins.update.success", scope: "decidim.system")
            redirect_to admins_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("admins.update.error", scope: "decidim.system")
            render :edit
          end
        end
      end

      def show
        @admin = Admin.find(params[:id])
      end

      def destroy
        @admin = Admin.find(params[:id]).destroy!
        flash[:notice] = I18n.t("admins.destroy.success", scope: "decidim.system")

        redirect_to admins_path
      end
    end
  end
end
