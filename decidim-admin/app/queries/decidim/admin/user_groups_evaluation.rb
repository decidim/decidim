# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to find the ParticipatoryProcesses that the given user can
    # manage.
    class UserGroupsEvaluation < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User Group that needs to be listed.
      def self.for(user_groups, q = nil, state = nil)
        new(user_groups, q, state).query
      end

      # Initializes the class.
      #
      # user_group - a User groups that need to be lsited
      def initialize(user_groups, q = nil, state = nil)
        @user_groups = user_groups
        @q = q
        @state = state
      end

      # List the User groups by the diferents filters.
      def query
        @user_groups = filter_by_search(@user_groups)
        @user_groups = filter_by_state(@user_groups)
        @user_groups
      end

      private

      attr_reader :user_group

      def filter_by_search(user_groups)
        return user_groups if @q.blank?
        user_groups.where("LOWER(name) LIKE LOWER('%#{@q}%')")
      end

      def filter_by_state(user_groups)
        case @state
        when "verified"
          user_groups.where.not(verified_at: nil)
        when "rejected"
          user_groups.where.not(rejected_at: nil)
        when "pending"
          user_groups.where(verified_at: nil, rejected_at: nil)
        else
          user_groups
        end
      end
    end
  end
end
