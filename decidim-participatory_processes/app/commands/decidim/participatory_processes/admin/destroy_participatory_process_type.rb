# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when destroying a participatory
      # process type in the system.
      class DestroyParticipatoryProcessType < Decidim::Command
        # Public: Initializes the command.
        #
        # participatory_process_type - A participatory_process_type object to
        # destroy
        # current_user - the user performing the action
        def initialize(participatory_process_type, current_user)
          @participatory_process_type = participatory_process_type
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_participatory_process_type!

          broadcast(:ok)
        end

        private

        attr_reader :current_user

        def destroy_participatory_process_type!
          transaction do
            Decidim.traceability.perform_action!(
              "delete",
              @participatory_process_type,
              current_user
            ) do
              @participatory_process_type.destroy!
            end
          end
        end
      end
    end
  end
end
