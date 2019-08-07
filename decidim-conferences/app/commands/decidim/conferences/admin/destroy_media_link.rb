# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a media link
      # in the system.
      class DestroyMediaLink < Rectify::Command
        # Public: Initializes the command.
        #
        # media_link - the MediaLink to destroy
        # current_user - the user performing this action
        def initialize(media_link, current_user)
          @media_link = media_link
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_speaker!
          broadcast(:ok)
        end

        private

        attr_reader :media_link, :current_user

        def destroy_speaker!
          log_info = {
            resource: {
              title: media_link.title
            },
            participatory_space: {
              title: media_link.conference.title
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            media_link,
            current_user,
            log_info
          ) do
            media_link.destroy!
            media_link
          end
        end
      end
    end
  end
end
