# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class ActivateParticipatoryProcessStep < Rectify::Command
      # Public: Initializes the command.
      #
      # step - A ParticipatoryProcessStep that will be activated
      def initialize(step)
        @step = step
      end

      # Executes the command. Braodcasts these events:
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
        Decidim::ParticipatoryProcessStep
          .where(decidim_participatory_process_id: step.decidim_participatory_process_id, active: true)
          .update_all(active: false)
      end

      def activate_step
        step.update_attribute(:active, true)
      end
    end
  end
end
