# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A class used to find the admins for an conference.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # conference - an conference that needs to find its conference admins
        def self.for(conference)
          new(conference).query
        end

        # Initializes the class.
        #
        # conference - an conference that needs to find its conference admins
        def initialize(conference)
          @conference = conference
        end

        # Finds organization admins and the users with role admin for the given conference.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins).or(conference_user_admins)
        end

        private

        attr_reader :conference

        def organization_admins
          conference.organization.admins
        end

        def conference_user_admins
          conference_user_admin_ids = Decidim::ConferenceUserRole
                                      .where(conference: conference, role: :admin)
                                      .pluck(:decidim_user_id)
          Decidim::User.where(id: conference_user_admin_ids)
        end
      end
    end
  end
end
