# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessStepsController < ApplicationController
      def new
        @form = ParticipatoryProcessStepForm.new
        authorize ParticipatoryProcessStep
      end

      def create
        @form = ParticipatoryProcessStepForm.from_params(params)
        authorize ParticipatoryProcessStep

        CreateParticipatoryProcessStep.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.create.success", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @participatory_process_step = collection.find(params[:id])
        authorize @participatory_process_step
        @form = ParticipatoryProcessStepForm.from_model(@participatory_process_step)
      end

      def update
        @participatory_process_step = collection.find(params[:id])
        authorize @participatory_process_step
        @form = ParticipatoryProcessStepForm.from_params(params)

        UpdateParticipatoryProcessStep.call(@participatory_process_step, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.update.success", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @participatory_process_step = collection.find(params[:id])
        authorize @participatory_process_step
      end

      def destroy
        @participatory_process_step = collection.find(params[:id])
        authorize @participatory_process_step

        @participatory_process_step.destroy!

        flash[:notice] = I18n.t("participatory_process_steps.destroy.success", scope: "decidim.admin")

        redirect_to participatory_process_path(@participatory_process_step.participatory_process)
      end

      private

      def participatory_process
        @participatory_process ||= current_organization.participatory_processes.find(params[:participatory_process_id])
      end

      def collection
        @collection ||= participatory_process.steps
      end

      def policy_class(_record)
        Decidim::Admin::ParticipatoryProcessPolicy
      end
    end
  end
end
