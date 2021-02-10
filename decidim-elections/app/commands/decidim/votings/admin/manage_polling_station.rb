# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the shared business logic to manage a polling station
      class ManagePollingStation < Rectify::Command
        def manage_polling_officers(polling_station, president_id, managers_ids)
          manage_president(polling_station, president_id)
          manage_managers(polling_station, managers_ids)
        end

        private

        def manage_president(polling_station, president_id)
          unassign_president(polling_station)
          return if president_id.nil?

          assign_president(president_id, polling_station)
        end

        def unassign_president(polling_station)
          assign_president(polling_station.polling_station_president.id, nil) if polling_station.polling_station_president.present?
        end

        def assign_president(president_id, polling_station)
          polling_station_president = PollingOfficer.find_by(id: president_id)
          polling_station_president.presided_polling_station = polling_station
          polling_station_president.save!
        end

        def manage_managers(polling_station, managers_ids)
          unassign_all_managers(polling_station)
          assign_new_managers(polling_station, managers_ids)
        end

        def unassign_all_managers(polling_station)
          polling_station.polling_station_managers.each do |manager|
            manager.managed_polling_station = nil
            manager.save!
          end
        end

        def assign_new_managers(polling_station, managers_ids)
          managers_ids.each do |manager_id|
            polling_station_manager = PollingOfficer.find_by(id: manager_id)
            polling_station_manager.managed_polling_station = polling_station
            polling_station_manager.save!
          end
        end
      end
    end
  end
end
