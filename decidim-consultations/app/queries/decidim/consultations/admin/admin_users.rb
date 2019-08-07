# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A class used to find the admins for a participatory process including
      # organization admins.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # consultation - a process that needs to find its process admins
        def self.for(consultation)
          new(consultation).query
        end

        # Initializes the class.
        #
        # consultation - a consultation that needs to find its process admins
        def initialize(consultation)
          @consultation = consultation
        end

        # Finds organization admins and the users with role admin for the given process.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins)
        end

        private

        attr_reader :consultation

        def organization_admins
          consultation.organization.admins
        end
      end
    end
  end
end
