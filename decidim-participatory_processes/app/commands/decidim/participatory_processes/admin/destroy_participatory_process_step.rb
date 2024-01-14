# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets all steps in a participatory process as inactive
      class DestroyParticipatoryProcessStep < Decidim::Commands::DestroyResource
        private

        def participatory_process = resource.participatory_space

        def invalid?
          participatory_process.steps.count > 1 && resource.active?
        end

        def run_after_hooks
          steps = participatory_process.steps.reload

          ReorderParticipatoryProcessSteps
            .new(steps, steps.map(&:id))
            .call
        end
      end
    end
  end
end
