# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing participatory process step ordering.
    #
    class ParticipatoryProcessStepOrderingController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        authorize! :reorder, Decidim::ParticipatoryProcessStep
        ReorderParticipatoryProcessSteps.call(collection, params[:items_ids]) do
          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin")
            redirect_to participatory_process_path(participatory_process)
          end
        end
      end

      private

      def collection
        participatory_process.steps
      end
    end
  end
end
