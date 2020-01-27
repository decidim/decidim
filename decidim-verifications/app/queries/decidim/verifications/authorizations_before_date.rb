# frozen_string_literal: true

module Decidim
  module Verifications
    # Finds authorizations by different criteria
    class AuthorizationsBeforeDate < Rectify::Query
      # Initializes the class.
      #
      # @param organization [Organization] The organization where this authorization belongs to
      # @param date [Date] The verification's date of an authorization
      # @param granted [boolean] Whether granted auths or not
      # @param impersonated_only [boolean] Whether impersonated or not
      def initialize(organization:, date:, granted:, impersonated_only: nil)
        @organization = organization
        @date = date
        @granted = granted
        @impersonated_only = impersonated_only
      end

      # Finds the Authorizations for the given method
      #
      # Returns an ActiveRecord::Relation.
      def query
        scope = Decidim::Authorization.left_outer_joins(:organization).where(decidim_organizations: { id: organization.id })

        scope = scope.where("#{Decidim::Authorization.table_name}.created_at < ?", date) unless date.nil?

        if granted == true
          scope = scope.where.not(granted_at: nil)
        elsif granted == false
          scope = scope.where(granted_at: nil)
        end

        # if impersonated_only == true
        #   scope = scope.where.not(granted_at: nil)
        # elsif impersonated_only == false
        #   scope = scope.where(granted_at: nil)
        # end

        scope
      end

      private

      attr_reader :organization, :date, :granted, :impersonated_only
    end
  end
end
