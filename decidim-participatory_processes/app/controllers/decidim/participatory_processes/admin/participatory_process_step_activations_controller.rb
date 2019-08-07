# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process step activations.
      #
      class ParticipatoryProcessStepActivationsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def create
          enforce_permission_to :activate, :process_step, process_step: process_step

          ActivateParticipatoryProcessStep.call(process_step, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_step_activations.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_step_activations.create.error", scope: "decidim.admin")
            end

            redirect_to participatory_process_steps_path(current_participatory_process)
          end
        end

        private

        def process_step
          collection.find(params[:step_id])
        end

        def collection
          current_participatory_process.steps
        end
      end
    end
  end
end
