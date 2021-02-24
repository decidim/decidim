# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class join the polling officers with their respective decidim user.
      class PollingOfficersJoinUser < Rectify::Query
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

        # Joins the polling officers with their associated decidim user.
        #
        # Returns an ActiveRecord::Relation.
        def query
          @polling_officers
            .joins("LEFT JOIN decidim_users ON decidim_users.id = decidim_votings_polling_officers.decidim_user_id")
        end
      end
    end
  end
end
