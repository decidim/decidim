# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdateMediaLink < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # media_link - The ConferenceSpeaker to update
        def initialize(form, media_link)
          @form = form
          @media_link = media_link
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless media_link

          transaction do
            update_media_link!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :media_link

        def update_media_link!
          log_info = {
            resource: {
              title: media_link.title
            },
            participatory_space: {
              title: media_link.conference.title
            }
          }

          Decidim.traceability.update!(
            media_link,
            form.current_user,
            form.attributes.slice(
              "title",
              "link",
              "weight",
              "date"
            ).symbolize_keys,
            log_info
          )
        end
      end
    end
  end
end
