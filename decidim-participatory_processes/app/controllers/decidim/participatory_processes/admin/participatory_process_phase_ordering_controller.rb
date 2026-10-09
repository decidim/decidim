# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process phase ordering.
      #
      class ParticipatoryProcessPhaseOrderingController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def create
          enforce_permission_to :reorder, :process_phase
          ReorderParticipatoryProcessPhases.call(collection, params[:items_ids]) do
            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_phases.ordering.error", scope: "decidim.admin")
              redirect_to participatory_process_path(current_participatory_process)
            end
          end
        end

        private

        def collection
          current_participatory_process.phases
        end
      end
    end
  end
end
