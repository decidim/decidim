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
        query = Decidim::Authorization.left_outer_joins(:organization).where(decidim_organizations: { id: organization.id })

        if impersonated_only == true
          query = query
                  .left_outer_joins(:user)
                  .where(decidim_users: { decidim_organization_id: organization.id })
                  .where(decidim_users: { managed: true })
        end

        query = query.where("#{Decidim::Authorization.table_name}.created_at < ?", date) unless date.nil?

        if granted == true
          query = query.where.not(granted_at: nil)
        elsif granted == false
          query = query.where(granted_at: nil)
        end

        query
      end

      private

      attr_reader :organization, :date, :granted, :impersonated_only
    end
  end
end
