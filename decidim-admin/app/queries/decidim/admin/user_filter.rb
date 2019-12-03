# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by whitelisted scope or searches on their
    # name
    class UserFilter < Rectify::Query
      WHITELISTED_STATE_SCOPES = %w(
        officialized
        not_officialized
        managed
        not_managed
      ).freeze

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # query - query to filter user by name, nickname and email
      # state - evaluation state to be used as a filter
      def self.for(scope, query = nil, state = nil)
        new(scope, query, state).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # search_query - query to filter user by name, nickname and email
      # state - users state, must be defined as a scope in the user model
      def initialize(scope, search_query = nil, state = nil)
        @scope = scope
        @search_query = search_query
        @state = state
      end

      # List the User groups by the diferents filters.
      def query
        users = scope
        users = filter_by_search(users)
        users = filter_by_state(users)
        users
      end

      private

      attr_reader :search_query, :state, :scope

      def filter_by_search(users)
        return users if search_query.blank?

        users.where("LOWER(name) LIKE LOWER(?) OR LOWER(nickname) LIKE LOWER(?) OR LOWER(email) = LOWER(?)", "%#{search_query}%", "%#{search_query}%", "%#{search_query}%")
      end

      def filter_by_state(users)
        return users unless WHITELISTED_STATE_SCOPES.include?(state)

        users.public_send(state)
      end
    end
  end
end
