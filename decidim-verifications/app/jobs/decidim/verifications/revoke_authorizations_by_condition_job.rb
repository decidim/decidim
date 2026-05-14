# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeAuthorizationsByConditionJob < Decidim::ApplicationJob
      queue_as :default

      # Revokes the organization's granted authorizations created before
      # the given date, optionally limited to impersonated users only.
      #
      # @param organization [Decidim::Organization] The organization whose authorizations will be revoked
      # @param current_user [Decidim::User] the current user.
      # @param before_date [Date] Only authorizations created before this date are revoked
      # @param impersonated_only [Boolean] When true, only impersonated users' authorizations are revoked
      def perform(organization, current_user, before_date, impersonated_only)
        authorizations_to_revoke = if impersonated_only
                                     Decidim::Verifications::AuthorizationsBeforeDate.new(
                                       organization:,
                                       date: before_date,
                                       granted: true,
                                       impersonated_only:
                                     )
                                   else
                                     Decidim::Verifications::AuthorizationsBeforeDate.new(
                                       organization:,
                                       date: before_date,
                                       granted: true
                                     )
                                   end

        auths = authorizations_to_revoke.query.includes(transfers: :records)
        auths.find_each do |auth|
          Decidim.traceability.perform_action!(
            :destroy,
            auth,
            current_user
          ) do
            auth.destroy
          end
        end
      end
    end
  end
end
