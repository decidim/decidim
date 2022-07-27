# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the shared business logic to manage a polling station
      class ManagePollingStation < Decidim::Command
        def manage_polling_officers(polling_station, president_id, managers_ids)
          manage_president(polling_station, president_id)
          manage_managers(polling_station, managers_ids)
        end

        private

        def manage_president(polling_station, president_id)
          unassign_president(polling_station)
          return if president_id.blank?

          assign_president(president_id, polling_station)
          notify_officer(president_id, polling_station.voting)
        end

        def unassign_president(polling_station)
          assign_president(polling_station.polling_station_president.id, nil) if polling_station.polling_station_president.present?
        end

        def assign_president(president_id, polling_station)
          polling_officer_for(president_id).update(presided_polling_station: polling_station)
        end

        def manage_managers(polling_station, managers_ids)
          unassign_managers(polling_station.polling_station_manager_ids - managers_ids)
          assign_managers(polling_station, managers_ids - polling_station.polling_station_manager_ids)
        end

        def unassign_managers(managers_ids)
          managers_ids.each { |manager_id| polling_officer_for(manager_id).update(managed_polling_station: nil) }
        end

        def assign_managers(polling_station, managers_ids)
          managers_ids.each do |manager_id|
            polling_officer_for(manager_id).update(managed_polling_station: polling_station)
            notify_officer(manager_id, polling_station.voting)
          end
        end

        def notify_officer(polling_officer_id, voting)
          Decidim::EventsManager.publish(
            event: "decidim.events.votings.polling_officers.polling_station_assigned",
            event_class: ::Decidim::Votings::PollingOfficers::PollingStationAssignedEvent,
            resource: voting,
            affected_users: [polling_officer_for(polling_officer_id).user],
            followers: [],
            extra: { polling_officer_id: }
          )
        end

        def polling_officer_for(polling_officer_id)
          PollingOfficer.find_by(id: polling_officer_id)
        end
      end
    end
  end
end
