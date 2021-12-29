# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class used to find the admins for a voting or an organization votings.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # voting - a voting that needs to find its voting admins
        def self.for(voting)
          new(voting).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its voting admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # voting - a voting that needs to find its voting admins
        # organization - an organization that needs to find its voting admins
        def initialize(voting, organization = nil)
          @voting = voting
          @organization = voting&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given voting.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins
        end

        private

        attr_reader :voting, :organization
      end
    end
  end
end
