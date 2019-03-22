# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A class used to find the admins for an initiative.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # initiative - Decidim::Initiative
        def self.for(initiative)
          new(initiative).query
        end

        # Initializes the class.
        #
        # initiative - Decidim::Initiative
        def initialize(initiative)
          @initiative = initiative
        end

        # Finds organization admins and the users with role admin for the given initiative.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins)
        end

        private

        attr_reader :initiative

        def organization_admins
          initiative.organization.admins
        end
      end
    end
  end
end
