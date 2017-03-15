# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing participatory processes.
    #
    class ParticipatoryProcessesController < ApplicationController
      helper_method :participatory_process
      helper Decidim::OrganizationScopesHelper
      layout "decidim/admin/participatory_process"

      def index
        authorize! :index, Decidim::ParticipatoryProcess
        @participatory_processes = collection
      end

      def new
        authorize! :new, Decidim::ParticipatoryProcess
        @form = form(ParticipatoryProcessForm).instance
      end

      def create
        authorize! :new, Decidim::ParticipatoryProcess
        @form = form(ParticipatoryProcessForm).from_params(params)

        CreateParticipatoryProcess.call(@form) do
          on(:ok) do |participatory_process|
            flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
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
        @form = form(ParticipatoryProcessForm).from_model(@participatory_process)
      end

      def update
        @participatory_process = collection.find(params[:id])
        authorize! :update, @participatory_process
        @form = form(ParticipatoryProcessForm).from_params(params)

        UpdateParticipatoryProcess.call(@participatory_process, @form) do
          on(:ok) do |participatory_process|
            flash[:notice] = I18n.t("participatory_processes.update.success", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
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
        render layout: "decidim/admin/participatory_process_show"
      end

      def destroy
        @participatory_process = collection.find(params[:id])
        authorize! :destroy, @participatory_process
        @participatory_process.destroy!

        flash[:notice] = I18n.t("participatory_processes.destroy.success", scope: "decidim.admin")

        redirect_to participatory_processes_path
      end

      private

      attr_reader :participatory_process

      def collection
        @collection ||= ManageableParticipatoryProcessesForUser.for(current_user)
      end
    end
  end
end
