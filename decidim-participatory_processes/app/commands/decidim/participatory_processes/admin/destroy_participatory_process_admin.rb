# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when destroying a participatory
      # process admin in the system.
      class DestroyParticipatoryProcessAdmin < Decidim::Command
        # Public: Initializes the command.
        #
        # role - the ParticipatoryProcessUserRole to destroy
        # current_user - the user performing this action
        def initialize(role, current_user)
          @role = role
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_role!
          broadcast(:ok)
        end

        private

        attr_reader :role, :current_user

        def destroy_role!
          extra_info = {
            resource: {
              title: role.user.name
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            role,
            current_user,
            extra_info
          ) do
            role.destroy!
            role
          end
        end
      end
    end
  end
end
