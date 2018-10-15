# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the accepted members of the given user group.
    class AcceptedUsers < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user_group - a UserGroup that needs to find its accepted members
      def self.for(user_group)
        new(user_group).query
      end

      # Initializes the class.
      #
      # user_group - a UserGroup that needs to find its accepted members
      def initialize(user_group)
        @user_group = user_group
      end

      # Finds the accepted members of the user group.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user_group
          .users
          .includes(:memberships)
          .where.not(decidim_user_group_memberships: { role: "requested" })
      end

      private

      attr_reader :user_group
    end
  end
end
