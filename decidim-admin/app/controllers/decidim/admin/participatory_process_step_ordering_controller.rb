# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessStepOrderingController < ApplicationController
      def create
        ReorderParticipatoryProcessSteps.call(collection, params[:items_ids]) do
          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin")
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
    end
  end
end
