# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A class used to find the admins for an initiative or an organization initiatives.
      class AdminUsers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # initiative - Decidim::Initiative
        def self.for(initiative)
          new(initiative).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its initiative admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # initiative - Decidim::Initiative
        # organization - an organization that needs to find its initiative admins
        def initialize(initiative, organization = nil)
          @initiative = initiative
          @organization = initiative&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given initiative.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins
        end

        private

        attr_reader :initiative, :organization
      end
    end
  end
end
