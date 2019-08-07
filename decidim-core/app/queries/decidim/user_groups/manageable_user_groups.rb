# frozen_string_literal: true

module Decidim
  module UserGroups
    # Use this class to find the user groups the given user can manage. In order
    # to calculate this, we get those groups where the user has a role of
    # creator or admin.
    class ManageableUserGroups < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which groups can manage
      def self.for(user)
        new(user).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which groups can manage
      def initialize(user)
        @user = user
      end

      # Finds the UserGroups where the user has a role of `:admin` or
      # `:creator`.
      #
      # Returns an ActiveRecord::Relation.
      def query
        user
          .user_groups
          .includes(:memberships)
          .where(decidim_user_group_memberships: { role: %w(admin creator) })
      end

      private

      attr_reader :user
    end
  end
end
