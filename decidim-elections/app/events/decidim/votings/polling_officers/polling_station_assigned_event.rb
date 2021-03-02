# frozen-string_literal: true

module Decidim
  module Votings
    module PollingOfficers
      class PollingStationAssignedEvent < Decidim::Events::SimpleEvent
        # This event sends a notification when a polling station is assigned to a polling officer

        delegate :organization, to: :user, prefix: false
        delegate :url_helpers, to: "Decidim::Core::Engine.routes"

        i18n_attributes :polling_station_name, :polling_officer_zone_url, :role

        def polling_station_name
          @polling_station_name ||= translated_attribute(polling_station.title)
        end

        def polling_officer_zone_url
          url_helpers.decidim_votings_polling_officer_zone_url(host: organization.host)
        end

        def role
          I18n.t(polling_officer.role, scope: "decidim.votings.polling_officers.roles")
        end

        private

        def polling_officer
          @polling_officer ||= Decidim::Votings::PollingOfficer.find_by(id: extra[:polling_officer_id])
        end

        def polling_station
          @polling_station ||=
            case polling_officer.role
            when :president
              polling_officer.presided_polling_station
            when :manager
              polling_officer.managed_polling_station
            end
        end
      end
    end
  end
end
