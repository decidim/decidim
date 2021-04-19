# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command is executed when the user updates a polling station
      # from the admin panel.
      class UpdatePollingStation < ManagePollingStation
        def initialize(form, polling_station)
          @form = form
          @polling_station = polling_station
        end

        # Updates the polling station if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_polling_station!
          manage_polling_officers(polling_station, form.polling_station_president_id, form.polling_station_manager_ids)

          broadcast(:ok, polling_station)
        end

        private

        attr_reader :form, :polling_station

        def update_polling_station!
          attributes = {
            title: form.title,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints
          }

          Decidim.traceability.update!(
            polling_station,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
