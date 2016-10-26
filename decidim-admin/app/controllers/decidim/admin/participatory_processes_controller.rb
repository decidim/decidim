# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessesController < ApplicationController
      def index
        authorize! :index, Decidim::ParticipatoryProcess
        @participatory_processes = collection
      end

      def new
        authorize! :new, Decidim::ParticipatoryProcess
        @form = ParticipatoryProcessForm.new
      end

      def create
        @form = ParticipatoryProcessForm.from_params(params)

        CreateParticipatoryProcess.call(@form, current_organization) do
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
        @form = ParticipatoryProcessForm.from_model(@participatory_process)
      end

      def update
        @participatory_process = collection.find(params[:id])
        @form = ParticipatoryProcessForm.from_params(params)

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
        @participatory_process.destroy!

        flash[:notice] = I18n.t("participatory_processes.destroy.success", scope: "decidim.admin")

        redirect_to participatory_processes_path
      end

      private

      def collection
        current_organization.participatory_processes
      end
    end
  end
end
