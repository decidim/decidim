# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter organization users
    class OrganizationUsers < Rectify::Query
      WHITELISTED_STATE_SCOPES = %w(
        officialized
        not_officialized
        managed
        not_managed
      ).freeze

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - the Decidim::Organization where search will be scoped to
      # name_query - query to filter user group names
      # state - evaluation state to be used as a filter
      def self.for(organization, name_query = nil, state = nil)
        new(organization, name_query, state).query
      end

      # Initializes the class.
      #
      # organization - the Decidim::Organization where search will be scoped to
      # name_query - query to filter user group names
      # state - users state, must be defined as a scope in the user model
      def initialize(organization, name_query = nil, state = nil)
        @organization = organization
        @name_query = name_query
        @state = state
      end

      # List the User groups by the diferents filters.
      def query
        users = organization.users
        users = filter_by_search(users)
        users = filter_by_state(users)
        users
      end

      private

      attr_reader :name_query, :state, :organization

      def filter_by_search(users)
        return users if name_query.blank?
        users.where("LOWER(name) LIKE LOWER(?)", "%#{name_query}%")
      end

      def filter_by_state(users)
        return users unless WHITELISTED_STATE_SCOPES.include?(state)

        users.public_send(state)
      end
    end
  end
end
