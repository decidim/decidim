# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets all steps in a participatory process as inactive
      class DestroyParticipatoryProcessStep < Decidim::Command
        # Public: Initializes the command.
        #
        # step - A ParticipatoryProcessStep that will be deactivated
        # current_user - the user performing the action
        def initialize(step, current_user)
          @step = step
          @participatory_process = step.participatory_process
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, :active_step) if active_step?

          transaction do
            Decidim.traceability.perform_action!(:delete, step, current_user) do
              step.destroy!
              step
            end

            reorder_steps
          end

          broadcast(:ok)
        end

        private

        attr_reader :step, :participatory_process, :current_user

        def active_step?
          participatory_process.steps.count > 1 && step.active?
        end

        def reorder_steps
          steps = participatory_process.steps.reload

          ReorderParticipatoryProcessSteps
            .new(steps, steps.map(&:id))
            .call
        end
      end
    end
  end
end
