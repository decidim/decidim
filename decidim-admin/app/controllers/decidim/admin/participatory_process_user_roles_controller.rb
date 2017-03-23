# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing participatory process user roles.
    #
    class ParticipatoryProcessUserRolesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :participatory_process, :process_admin_roles

      def index
        authorize! :read, Decidim::Admin::ParticipatoryProcessUserRole
      end

      def new
        authorize! :create, Decidim::Admin::ParticipatoryProcessUserRole
        @form = form(ParticipatoryProcessUserRoleForm).instance
      end

      def create
        authorize! :create, Decidim::Admin::ParticipatoryProcessUserRole
        @form = form(ParticipatoryProcessUserRoleForm).from_params(params)

        CreateParticipatoryProcessAdmin.call(@form, current_user, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_user_roles.create.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("participatory_process_user_roles.create.error", scope: "decidim.admin")
          end
          redirect_to participatory_process_user_roles_path(participatory_process)
        end
      end

      def edit
        @user_role = collection.find(params[:id])
        authorize! :update, @user_role
        @form = form(ParticipatoryProcessUserRoleForm).from_model(@user_role.user, current_process: participatory_process)
      end

      def update
        @user_role = collection.find(params[:id])
        authorize! :update, @user_role
        @form = form(ParticipatoryProcessUserRoleForm).from_params(params, current_process: participatory_process)

        UpdateParticipatoryProcessAdmin.call(@user_role, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("user_roles.update.success", scope: "decidim.admin")
            redirect_to participatory_process_user_roles_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("user_roles.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        @participatory_process_user_role = collection.find(params[:id])
        authorize! :destroy, @participatory_process_user_role
        @participatory_process_user_role.destroy!

        flash[:notice] = I18n.t("participatory_process_user_roles.destroy.success", scope: "decidim.admin")

        redirect_to participatory_process_user_roles_path(@participatory_process_user_role.participatory_process)
      end

      private

      def collection
        @collection ||= ProcessAdminRolesForProcess.for(participatory_process)
      end

      def process_admin_roles
        @process_admin_roles ||= ProcessAdminRolesForProcess.for(@participatory_process)
      end
    end
  end
end
