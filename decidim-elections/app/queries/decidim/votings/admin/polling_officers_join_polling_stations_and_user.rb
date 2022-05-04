# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class join the polling officers with their respective polling stations and users.
      class PollingOfficersJoinPollingStationsAndUser < Decidim::Query
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

        # Finds joins the polling officers with their associated polling stations and users.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::Query.merge(
            PollingOfficersJoinPollingStations.new(@polling_officers),
            PollingOfficersJoinUser.new(@polling_officers)
          ).query
        end
      end
    end
  end
end
