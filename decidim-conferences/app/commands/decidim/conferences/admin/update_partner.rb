# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdatePartner < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference_partner - The ConferencePartner to update
        def initialize(form, conference_partner)
          @form = form
          @conference_partner = conference_partner
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless conference_partner

          update_conference_partner!
          broadcast(:ok)
        end

        private

        attr_reader :form, :conference_partner

        def update_conference_partner!
          log_info = {
            resource: {
              title: conference_partner.name
            },
            participatory_space: {
              title: conference_partner.conference.title
            }
          }

          Decidim.traceability.update!(
            conference_partner,
            form.current_user,
            form.attributes.slice(
              :name,
              :weight,
              :partner_type,
              :link,
              :logo,
              :remove_logo
            ),
            log_info
          )
        end
      end
    end
  end
end
