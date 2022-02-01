# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the user groups the given user is accepted. In order
    # to calculate this, we get those groups where the user has a role of
    # member, creator or admin.
    class AcceptedUserGroups < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find the groups where they are accepted
      def self.for(user)
        new(user).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find the groups where they are accepted
      def initialize(user)
        @user = user
      end

      # Finds the UserGroups where the user has an accepted membership.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user
          .user_groups
          .includes(:memberships)
          .where(decidim_user_group_memberships: { role: %w(creator admin member) })
      end

      private

      attr_reader :user
    end
  end
end
