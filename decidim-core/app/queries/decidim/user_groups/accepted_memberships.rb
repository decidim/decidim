# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the accepted memberships of the given user group.
    class AcceptedMemberships < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user_group - a UserGroup that needs to find its accepted memberships
      def self.for(user_group)
        new(user_group).query
      end

      # Initializes the class.
      #
      # user_group - a UserGroup that needs to find its accepted memberships
      def initialize(user_group)
        @user_group = user_group
      end

      # Finds the accepted memberships of the user group.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user_group
          .non_deleted_memberships
          .includes(:user)
          .where(role: %w(creator admin member))
      end

      private

      attr_reader :user_group
    end
  end
end
