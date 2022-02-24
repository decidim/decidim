# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to destroy a poling officer
      class DestroyPollingOfficer < Decidim::Command
        # Public: Initializes the command.
        #
        # polling_officer - the PollingOfficer to destroy
        # current_user - the user performing this action
        def initialize(polling_officer, current_user)
          @polling_officer = polling_officer
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_polling_officer!
          broadcast(:ok)
        end

        private

        attr_reader :polling_officer, :current_user

        def destroy_polling_officer!
          extra_info = {
            resource: {
              title: polling_officer.user.name
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            polling_officer,
            current_user,
            extra_info
          ) do
            polling_officer.destroy!
            polling_officer
          end
        end
      end
    end
  end
end
