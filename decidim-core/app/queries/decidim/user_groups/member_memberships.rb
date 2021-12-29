# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the the members of the given user group with the
    # "member" role. It returns memberships.
    class MemberMemberships < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user_group - a UserGroup that needs to find its member users
      def self.for(user_group)
        new(user_group).query
      end

      # Initializes the class.
      #
      # user_group - a UserGroup that needs to find its member users
      def initialize(user_group)
        @user_group = user_group
      end

      # Finds the member users of the user group.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user_group
          .non_deleted_memberships
          .includes(:user)
          .where(role: :member)
      end

      private

      attr_reader :user_group
    end
  end
end
