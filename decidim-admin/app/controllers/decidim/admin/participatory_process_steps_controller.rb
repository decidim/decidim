# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing participatory process steps.
    #
    class ParticipatoryProcessStepsController < Decidim::Admin::ApplicationController
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

        CreateParticipatoryProcessStep.call(@form, current_participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.create.success", scope: "decidim.admin")
            redirect_to participatory_process_steps_path(current_participatory_process)
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
            redirect_to participatory_process_steps_path(current_participatory_process)
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

        DestroyParticipatoryProcessStep.call(@participatory_process_step) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_steps.destroy.success", scope: "decidim.admin")
            redirect_to participatory_process_steps_path(current_participatory_process)
          end

          on(:invalid) do |reason|
            flash[:alert] = I18n.t("participatory_process_steps.destroy.error.#{reason}", scope: "decidim.admin")
            redirect_to participatory_process_steps_path(current_participatory_process)
          end
        end
      end

      private

      def collection
        @collection ||= current_participatory_process.steps
      end
    end
  end
end
