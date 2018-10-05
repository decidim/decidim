# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new partner
      # in the system.
      class CreatePartner < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference - The Conference that will hold the speaker
        def initialize(form, current_user, conference)
          @form = form
          @current_user = current_user
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_partner!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference, :current_user

        def create_partner!
          log_info = {
            resource: {
              title: form.name
            },
            participatory_space: {
              title: conference.title
            }
          }

          @partner = Decidim.traceability.create!(
            Decidim::Conferences::Partner,
            form.current_user,
            form.attributes.slice(
              :name,
              :weight,
              :link,
              :partner_type,
              :logo,
              :remove_avatar
            ).merge(
              conference: conference
            ),
            log_info
          )
        end
      end
    end
  end
end
