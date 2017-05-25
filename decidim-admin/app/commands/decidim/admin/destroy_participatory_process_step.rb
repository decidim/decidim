# frozen_string_literal: true

module Decidim
  module Admin
    # A command that sets all steps in a participatory process as inactive
    class DestroyParticipatoryProcessStep < Rectify::Command
      # Public: Initializes the command.
      #
      # step - A ParticipatoryProcessStep that will be deactivated
      def initialize(step)
        @step = step
        @participatory_process = step.participatory_process
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid, :last_step) if @participatory_process.steps.count == 1
        return broadcast(:invalid, :active_step) if @step.active?

        @step.destroy!
        reorder_steps
        broadcast(:ok)
      end

      private

      def reorder_steps
        steps = @participatory_process.steps.reload

        ReorderParticipatoryProcessSteps
          .new(steps, steps.map(&:id))
          .call
      end
    end
  end
end
