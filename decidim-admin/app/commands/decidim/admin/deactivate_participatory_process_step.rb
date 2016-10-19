# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when deactivating a participatory
    # process step.
    class DeactivateParticipatoryProcessStep < Rectify::Command
      # Public: Initializes the command.
      #
      # step - A ParticipatoryProcessStep that will be deactivated
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
        return broadcast(:invalid) if step.nil? || !step.active?

        deactivate_active_steps
        broadcast(:ok)
      end

      private

      attr_reader :step

      def deactivate_active_steps
        Decidim::ParticipatoryProcessStep
          .where(decidim_participatory_process_id: step.decidim_participatory_process_id, active: true)
          .update_all(active: false)
      end
    end
  end
end
