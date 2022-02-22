# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying an conference
      # partner in the system.
      class DestroyPartner < Decidim::Command
        # Public: Initializes the command.
        #
        # conference_partner - the Partner to destroy
        # current_user - the user performing this action
        def initialize(conference_partner, current_user)
          @conference_partner = conference_partner
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_partner!
          broadcast(:ok)
        end

        private

        attr_reader :conference_partner, :current_user

        def destroy_partner!
          log_info = {
            resource: {
              title: conference_partner.name
            },
            participatory_space: {
              title: conference_partner.conference.title
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            conference_partner,
            current_user,
            log_info
          ) do
            conference_partner.destroy!
            conference_partner
          end
        end
      end
    end
  end
end
