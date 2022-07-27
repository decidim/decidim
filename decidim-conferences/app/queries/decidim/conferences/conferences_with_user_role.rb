# frozen_string_literal: true

module Decidim
  module Conferences
    # A class used to find the Conferences that the given user has
    # the specific role privilege.
    class ConferencesWithUserRole < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which conferences can manage
      # role - (optional) a Symbol to specify the role privilege
      def self.for(user, role = :any)
        new(user, role).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which conferences can manage
      # role - (optional) a Symbol to specify the role privilege
      def initialize(user, role = :any)
        @user = user
        @role = role
      end

      # Finds the Conferences that the given user has role privileges.
      # If the special role ':any' is provided it returns all conferences where
      # the user has some kind of role privilege.
      #
      # Returns an ActiveRecord::Relation.
      def query
        # Admin users have all role privileges for all organization conferences
        return Conferences::OrganizationConferences.new(user.organization).query if user.admin?

        Conference.where(id: conference_ids)
      end

      private

      attr_reader :user, :role

      def conference_ids
        user_roles = ConferenceUserRole.where(user:) if role == :any
        user_roles = ConferenceUserRole.where(user:, role:) if role != :any
        user_roles.pluck(:decidim_conference_id)
      end
    end
  end
end
