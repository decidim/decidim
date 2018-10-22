# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the the members of the given user group with the
    # "member" role.
    class MemberUsers < Rectify::Query
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
          .users
          .includes(:memberships)
          .where(decidim_user_group_memberships: { role: :member })
      end

      private

      attr_reader :user_group
    end
  end
end
