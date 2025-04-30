# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by allowed scope or searches on their
    # name
    class UserFilter < Decidim::Query
      ALLOWED_STATE_SCOPES = %w(
        officialized
        not_officialized
        managed
        not_managed
      ).freeze

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user names
      # state - evaluation state to be used as a filter
      def self.for(scope, name_query = nil, state = nil)
        new(scope, name_query, state).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user names
      # state - users state, must be defined as a scope in the user model
      def initialize(scope, name_query = nil, state = nil)
        @scope = scope
        @name_query = name_query
        @state = state
      end

      # List the Users by the different filters.
      def query
        users = scope
        users = filter_by_search(users)
        filter_by_state(users)
      end

      private

      attr_reader :name_query, :state, :scope

      def filter_by_search(users)
        return users if name_query.blank?

        users.where("LOWER(name) LIKE LOWER(?)", "%#{name_query}%")
      end

      def filter_by_state(users)
        return users unless ALLOWED_STATE_SCOPES.include?(state)

        users.public_send(state)
      end
    end
  end
end
