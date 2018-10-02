# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command that sets an conference as unpublished.
      class UnpublishConference < Rectify::Command
        # Public: Initializes the command.
        #
        # conference - A Conference that will be published
        # current_user - the user performing the action
        def initialize(conference, current_user)
          @conference = conference
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if conference.nil? || !conference.published?

          Decidim.traceability.perform_action!("unpublish", conference, current_user) do
            conference.unpublish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :conference, :current_user
      end
    end
  end
end
