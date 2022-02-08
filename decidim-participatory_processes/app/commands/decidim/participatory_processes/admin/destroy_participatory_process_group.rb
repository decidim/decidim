# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when deleting a ParticipatoryProcessGroup.
      class DestroyParticipatoryProcessGroup < Decidim::Command
        # Public: Initializes the command.
        #
        # participatory_process_group - the ParticipatoryProcessGroup to delete.
        # current_user - the user performing this action
        def initialize(participatory_process_group, current_user)
          @participatory_process_group = participatory_process_group
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when the record could be deleted.
        # - :invalid when the record couldn't be deleted.
        #
        # Returns nothing.
        def call
          destroy_process_group
          broadcast(:ok)
        rescue ActiveRecord::RecordNotDestroyed
          broadcast(:invalid)
        end

        private

        attr_reader :participatory_process_group, :current_user

        def destroy_process_group
          Decidim.traceability.perform_action!(
            "delete",
            participatory_process_group,
            current_user
          ) do
            participatory_process_group.destroy!
          end
        end
      end
    end
  end
end
