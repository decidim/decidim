# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # registration type in the system.
      class DestroyRegistrationType < Decidim::Command
        # Public: Initializes the command.
        #
        # registration_type - the Partner to destroy
        # current_user - the user performing this action
        def initialize(registration_type, current_user)
          @registration_type = registration_type
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_registration_type!
          broadcast(:ok)
        end

        private

        attr_reader :registration_type, :current_user

        def destroy_registration_type!
          log_info = {
            resource: {
              title: registration_type.title
            },
            participatory_space: {
              title: registration_type.conference.title
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            registration_type,
            current_user,
            log_info
          ) do
            registration_type.destroy!
            registration_type
          end
        end
      end
    end
  end
end
