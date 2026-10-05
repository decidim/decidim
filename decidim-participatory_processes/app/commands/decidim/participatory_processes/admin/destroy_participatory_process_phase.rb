# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that deletes a participatory process phase
      class DestroyParticipatoryProcessPhase < Decidim::Commands::DestroyResource
        private

        def participatory_process = resource.participatory_space

        def invalid?
          participatory_process.phases.count > 1 && resource.active?
        end

        def run_after_hooks
          phases = participatory_process.phases.reload

          ReorderParticipatoryProcessPhases
            .new(phases, phases.map(&:id))
            .call
        end
      end
    end
  end
end
