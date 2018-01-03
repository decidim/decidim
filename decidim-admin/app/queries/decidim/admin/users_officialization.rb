# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter User's by their officialization state.
    class UsersOfficialization < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # q - query to filter user group names
      # state - evaluation state to be used as a filter
      def self.for(q = nil, state = nil)
        new(q, state).query
      end

      # Initializes the class.
      #
      # q - query to filter user group names
      # state - officialization state to be used as a filter
      def initialize(q = nil, state = nil)
        @q = q
        @state = state
      end

      # List the User groups by the diferents filters.
      def query
        users = Decidim::User.all
        users = filter_by_search(users)
        users = filter_by_state(users)
        users
      end

      private

      attr_reader :q, :state

      def filter_by_search(users)
        return users if q.blank?
        users.where("LOWER(name) LIKE LOWER(?)", "%#{q}%")
      end

      def filter_by_state(users)
        case state
        when "officialized"
          users.where.not(officialized_at: nil)
        when "not_officialized"
          users.where(officialized_at: nil)
        else
          users
        end
      end
    end
  end
end
