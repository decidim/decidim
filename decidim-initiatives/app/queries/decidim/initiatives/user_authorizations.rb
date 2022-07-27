# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class used the retrieve the authorizations for a user.
    class UserAuthorizations < Decidim::Query
      attr_reader :user

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - Decidim::User
      def self.for(user)
        new(user).query
      end

      # Retrieves authorizations for the given user
      #
      # user - Decidim::User
      def initialize(user)
        @user = user
      end

      # Retrieves authorizations for the given user.
      def query
        Authorization.where(user:).where.not(granted_at: nil)
      end
    end
  end
end
