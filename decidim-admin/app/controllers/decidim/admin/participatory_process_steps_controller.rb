# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessStepsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, Decidim::ParticipatoryProcessStep
      end

      def new
        authorize! :create, Decidim::ParticipatoryProcessStep
        @form = form(ParticipatoryProcessStepForm).instance
      end

      def create
        authorize! :create, Decidim::ParticipatoryProcessStep
        @form = form(ParticipatoryProcessStepForm).from_params(params)

        CreateParticipatoryProcessStep.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.create.success", scope: "decidim.admin")
            redirect_to participatory_process_steps_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @participatory_process_step = collection.find(params[:id])
        authorize! :update, @participatory_process_step
        @form = form(ParticipatoryProcessStepForm).from_model(@participatory_process_step)
      end

      def update
        @participatory_process_step = collection.find(params[:id])
        authorize! :update, @participatory_process_step
        @form = form(ParticipatoryProcessStepForm).from_params(params)

        UpdateParticipatoryProcessStep.call(@participatory_process_step, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.update.success", scope: "decidim.admin")
            redirect_to participatory_process_steps_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @participatory_process_step = collection.find(params[:id])
        authorize! :read, @participatory_process_step
      end

      def destroy
        @participatory_process_step = collection.find(params[:id])
        authorize! :destroy, @participatory_process_step
        @participatory_process_step.destroy!

        flash[:notice] = I18n.t("participatory_process_steps.destroy.success", scope: "decidim.admin")

        redirect_to participatory_process_steps_path(@participatory_process_step.participatory_process)
      end

      private

      def collection
        @collection ||= participatory_process.steps
      end
    end
  end
end
