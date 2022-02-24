# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class join the polling officers with their respective polling stations.
      class PollingOfficersJoinPollingStations < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # polling_officers - the collection of polling officers
        def self.for(polling_officers)
          new(polling_officers).query
        end

        # Initializes the class.
        #
        # polling_officers - the collection of polling officers
        def initialize(polling_officers)
          @polling_officers = polling_officers
        end

        # Finds joins the polling officers with their associated polling stations.
        #
        # Returns an ActiveRecord::Relation.
        def query
          @polling_officers
            .joins("LEFT JOIN decidim_votings_polling_stations presided_station ON decidim_votings_polling_officers.presided_polling_station_id = presided_station.id
                    LEFT JOIN decidim_votings_polling_stations managed_station ON decidim_votings_polling_officers.managed_polling_station_id = managed_station.id")
        end
      end
    end
  end
end
