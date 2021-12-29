# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A class used to find the admins for a consultation or an organization consultations.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # consultation - a consultation that needs to find its consultation admins
        def self.for(consultation)
          new(consultation).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its consultation admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # consultation - a consultation that needs to find its consultation admins
        # organization - an organization that needs to find its consultation admins
        def initialize(consultation, organization = nil)
          @consultation = consultation
          @organization = consultation&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given consultation.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins
        end

        private

        attr_reader :organization
      end
    end
  end
end
