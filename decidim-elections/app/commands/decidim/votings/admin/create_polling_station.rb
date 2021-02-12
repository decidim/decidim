# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with all the business logic when creating a new polling station
      class CreatePollingStation < ManagePollingStation
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          polling_station = create_polling_station!
          manage_polling_officers(polling_station, form.polling_station_president_id, form.polling_station_manager_ids)

          if polling_station.persisted?
            broadcast(:ok, polling_station)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_polling_station!
          params = {
            voting: form.voting,
            title: form.title,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints
          }

          Decidim.traceability.create!(
            PollingStation,
            form.current_user,
            params,
            visibility: "all"
          )
        end
      end
    end
  end
end
