# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessStepActivationsController < ApplicationController
      def create
        authorize ParticipatoryProcessStep

        ActivateParticipatoryProcessStep.call(collection.find(params[:step_id])) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_step_activations.create.success", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_step_activations.create.error", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
          end
        end
      end

      private

      def participatory_process
        current_organization.participatory_processes.find(params[:participatory_process_id])
      end

      def collection
        participatory_process.steps
      end

      def policy_class(_record)
        Decidim::Admin::ParticipatoryProcessPolicy
      end
    end
  end
end
