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
      # @param impersonated_only [Boolean] Whether to return impersonated auths only
      # @param before_date [Date] Only authorizations created before this date
      def initialize(organization:, user: nil, name: nil, granted: nil, impersonated_only: false, before_date: nil) # rubocop:disable Metrics/ParameterLists
        @organization = organization
        @user = user
        @name = name
        @granted = granted
        @impersonated_only = impersonated_only
        @before_date = before_date
      end

      # Finds the Authorizations for the given method
      #
      # Returns an ActiveRecord::Relation.
      def query
        scope = Decidim::Authorization.left_outer_joins(:organization).where(decidim_organizations: { id: organization.id })

        scope = scope.where(name:) unless name.nil?
        scope = scope.where(user:) unless user.nil?

        if impersonated_only
          scope = scope
                  .left_outer_joins(:user)
                  .where(decidim_users: { decidim_organization_id: organization.id, managed: true })
        end

        scope = scope.where("#{Decidim::Authorization.table_name}.created_at < ?", before_date) unless before_date.nil?

        case granted
        when true
          scope = scope.where.not(granted_at: nil)
        when false
          scope = scope.where(granted_at: nil)
        end

        scope
      end

      private

      attr_reader :user, :name, :granted, :organization, :impersonated_only, :before_date
    end
  end
end
