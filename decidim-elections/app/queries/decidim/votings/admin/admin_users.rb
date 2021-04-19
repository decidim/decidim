# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class used to find the admins for a voting including organization admins.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # voting - a voting that needs to find its voting admins
        def self.for(voting)
          new(voting).query
        end

        # Initializes the class.
        #
        # voting - a voting that needs to find its process admins
        def initialize(voting)
          @voting = voting
        end

        # Finds organization admins and the users with role admin for the given process.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins)
        end

        private

        attr_reader :voting

        def organization_admins
          voting.organization.admins
        end
      end
    end
  end
end
