# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a step in a participatory process as active (and
      # unsets a previous active step)
      class ActivateParticipatoryProcessStep < Rectify::Command
        # Public: Initializes the command.
        #
        # step - A ParticipatoryProcessStep that will be activated
        def initialize(step)
          @step = step
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if step.nil? || step.active?

          Decidim::ParticipatoryProcessStep.transaction do
            deactivate_active_steps
            activate_step
          end
          broadcast(:ok)
        end

        private

        attr_reader :step

        def deactivate_active_steps
          step.participatory_process.steps.where(active: true).each do |step|
            step.update_attributes!(active: false)
          end
        end

        def activate_step
          step.update_attributes!(active: true)
        end
      end
    end
  end
end
