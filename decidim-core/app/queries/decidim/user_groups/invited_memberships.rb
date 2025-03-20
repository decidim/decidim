# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the invitations to user groups the given user has.
    class InvitedMemberships < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which groups they have been invited to
      def self.for(user)
        new(user).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which groups they have been invited to
      def initialize(user)
        @user = user
      end

      # Finds the UserGroupMemberships the user has been invited to.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user
          .memberships
          .includes(:user_group)
          .where(role: "invited")
      end

      private

      attr_reader :user
    end
  end
end
