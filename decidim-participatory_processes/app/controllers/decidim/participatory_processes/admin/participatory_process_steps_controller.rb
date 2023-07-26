# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process steps.
      #
      class ParticipatoryProcessStepsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        before_action :find_participatory_process_step, except: [:index, :new, :create]
        before_action :set_controller_breadcrumb

        def index
          enforce_permission_to :read, :process_step
        end

        def new
          enforce_permission_to :create, :process_step
          @form = form(ParticipatoryProcessStepForm).instance
        end

        def create
          enforce_permission_to :create, :process_step
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
          enforce_permission_to :update, :process_step, process_step: @participatory_process_step
          @form = form(ParticipatoryProcessStepForm).from_model(@participatory_process_step)
        end

        def update
          enforce_permission_to :update, :process_step, process_step: @participatory_process_step
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
          enforce_permission_to :read, :process_step, process_step: @participatory_process_step
        end

        def destroy
          enforce_permission_to :destroy, :process_step, process_step: @participatory_process_step

          DestroyParticipatoryProcessStep.call(@participatory_process_step, current_user) do
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

        def find_participatory_process_step
          @participatory_process_step = collection.find(params[:id])
        end

        def set_controller_breadcrumb
          return if @participatory_process_step.blank?

          controller_breadcrumb_items << {
            label: translated_attribute(@participatory_process_step.title),
            active: true
          }
        end
      end
    end
  end
end
