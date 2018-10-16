# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the user groups the given user has a membership
    # that has yet to be accepted.
    class PendingUserGroups < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which groups they are pending to be accepted
      def self.for(user)
        new(user).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which groups they are pending to be accepted
      def initialize(user)
        @user = user
      end

      # Finds the UserGroups where the user has a membership that is pending to
      # be accepted.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user
          .user_groups
          .includes(:memberships)
          .where(decidim_user_group_memberships: { role: "requested" })
      end

      private

      attr_reader :user
    end
  end
end
