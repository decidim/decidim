# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command is executed when the user destroys a polling station
      # from the admin panel.
      class DestroyPollingStation < Rectify::Command
        def initialize(polling_station, current_user)
          @polling_station = polling_station
          @current_user = current_user
        end

        # Destroys the polling station if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_polling_station!

          broadcast(:ok, polling_station)
        end

        private

        attr_reader :polling_station, :current_user

        def destroy_polling_station!
          Decidim.traceability.perform_action!(
            :delete,
            polling_station,
            current_user,
            visibility: "all"
          ) do
            polling_station.destroy!
          end
        end
      end
    end
  end
end
