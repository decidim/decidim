# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessesController < ApplicationController
      helper_method :process_admin_roles

      def index
        authorize! :index, Decidim::ParticipatoryProcess
        @participatory_processes = collection
      end

      def new
        authorize! :new, Decidim::ParticipatoryProcess
        @form = ParticipatoryProcessForm.new
      end

      def create
        authorize! :new, Decidim::ParticipatoryProcess
        @form = ParticipatoryProcessForm.from_params(params, organization: current_organization)

        CreateParticipatoryProcess.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
            redirect_to participatory_processes_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_processes.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @participatory_process = collection.find(params[:id])
        authorize! :update, @participatory_process
        @form = ParticipatoryProcessForm.from_model(@participatory_process)
      end

      def update
        @participatory_process = collection.find(params[:id])
        authorize! :update, @participatory_process
        @form = ParticipatoryProcessForm.from_params(params, organization: current_organization)

        UpdateParticipatoryProcess.call(@participatory_process, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_processes.update.success", scope: "decidim.admin")
            redirect_to participatory_processes_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_processes.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @participatory_process = collection.find(params[:id])
        authorize! :read, @participatory_process
      end

      def destroy
        @participatory_process = collection.find(params[:id])
        authorize! :destroy, @participatory_process
        @participatory_process.destroy!

        flash[:notice] = I18n.t("participatory_processes.destroy.success", scope: "decidim.admin")

        redirect_to participatory_processes_path
      end

      private

      def collection
        @collection ||= ManageableParticipatoryProcessesForUser.for(current_user)
      end

      def process_admin_roles
        @process_admin_roles ||= ProcessAdminRolesForProcess.for(@participatory_process)
      end
    end
  end
end
