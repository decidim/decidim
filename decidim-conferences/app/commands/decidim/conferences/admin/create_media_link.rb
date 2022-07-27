# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # media link for conference in the system.
      class CreateMediaLink < Decidim::Command
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
            create_media_link!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference, :current_user

        def create_media_link!
          log_info = {
            resource: {
              title: form.title
            },
            participatory_space: {
              title: conference.title
            }
          }

          @media_link = Decidim.traceability.create!(
            Decidim::Conferences::MediaLink,
            current_user,
            form.attributes.slice(
              "title",
              "link",
              "weight",
              "date"
            ).symbolize_keys.merge(
              conference:
            ),
            log_info
          )
        end
      end
    end
  end
end
