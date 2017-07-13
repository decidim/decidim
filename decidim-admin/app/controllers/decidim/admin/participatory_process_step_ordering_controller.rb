# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing participatory process step ordering.
    #
    class ParticipatoryProcessStepOrderingController < Decidim::Admin::ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        authorize! :reorder, Decidim::ParticipatoryProcessStep
        ReorderParticipatoryProcessSteps.call(collection, params[:items_ids]) do
          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin")
            redirect_to participatory_process_path(current_participatory_process)
          end
        end
      end

      private

      def collection
        current_participatory_process.steps
      end
    end
  end
end
