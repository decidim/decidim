# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing participatory process step activations.
    #
    class ParticipatoryProcessStepActivationsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        authorize! :activate, process_step

        ActivateParticipatoryProcessStep.call(process_step) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_step_activations.create.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_step_activations.create.error", scope: "decidim.admin")
          end

          redirect_to participatory_process_steps_path(participatory_process)
        end
      end

      private

      def process_step
        collection.find(params[:step_id])
      end

      def collection
        participatory_process.steps
      end
    end
  end
end
