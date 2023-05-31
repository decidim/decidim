# frozen_string_literal: true

module Decidim
  module Verifications
    # Finds authorizations by different criteria
    class Authorizations < Decidim::Query
      # Initializes the class.
      #
      # @param organization [Organization] The organization where this authorization belongs to
      # @param name [String] The name of an authorization method
      # @param user [User] A user to find authorizations for
      # @param granted [Boolean] Whether the authorization is granted or not
      def initialize(organization:, user: nil, name: nil, granted: nil)
        @organization = organization
        @user = user
        @name = name
        @granted = granted
      end

      # Finds the Authorizations for the given method
      #
      # Returns an ActiveRecord::Relation.
      def query
        scope = Decidim::Authorization.left_outer_joins(:organization).where(decidim_organizations: { id: organization.id })

        scope = scope.where(name:) unless name.nil?
        scope = scope.where(user:) unless user.nil?

        case granted
        when true
          scope = scope.where.not(granted_at: nil)
        when false
          scope = scope.where(granted_at: nil)
        end

        scope
      end

      private

      attr_reader :user, :name, :granted, :organization
    end
  end
end
