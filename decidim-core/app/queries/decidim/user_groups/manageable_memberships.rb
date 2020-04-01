# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the the admins of the given user group with the
    # "admin" or "creator" role. It returns memberships.
    class ManageableMemberships < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user_group - a UserGroup that needs to find its admin users
      def self.for(user_group)
        new(user_group).query
      end

      # Initializes the class.
      #
      # user_group - a UserGroup that needs to find its admin users
      def initialize(user_group)
        @user_group = user_group
      end

      # Finds the admin or creator users of the user group.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user_group
          .memberships
          .includes(:user)
          .where(role: %w(creator admin))
      end

      private

      attr_reader :user_group
    end
  end
end
