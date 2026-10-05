# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process phase activations.
      #
      class ParticipatoryProcessPhaseActivationsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def create
          enforce_permission_to(:activate, :process_phase, process_phase:)

          ActivateParticipatoryProcessPhase.call(process_phase, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_phase_activations.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_phase_activations.create.error", scope: "decidim.admin")
            end

            redirect_to participatory_process_phases_path(current_participatory_process)
          end
        end

        private

        def process_phase
          collection.find(params.expect(:phase_id))
        end

        def collection
          current_participatory_process.phases
        end
      end
    end
  end
end
