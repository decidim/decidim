# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A class used to find the admins for an conference or an organization conferences.
      class AdminUsers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # conference - an conference that needs to find its conference admins
        def self.for(conference)
          new(conference).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its conference admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # conference - an conference that needs to find its conference admins
        # organization - an organization that needs to find its conference admins
        def initialize(conference, organization = nil)
          @conference = conference
          @organization = conference&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given conference.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins.or(conferences_user_admins)
        end

        private

        attr_reader :conference, :organization

        def conferences_user_admins
          Decidim::User.where(
            id: Decidim::ConferenceUserRole.where(conference: conferences, role: :admin)
                                           .select(:decidim_user_id)
          )
        end

        def conferences
          if conference
            [conference]
          else
            Decidim::Conference.where(organization:)
          end
        end
      end
    end
  end
end
