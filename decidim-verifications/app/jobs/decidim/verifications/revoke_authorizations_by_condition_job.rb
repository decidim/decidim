# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeAuthorizationsByConditionJob < Decidim::ApplicationJob
      queue_as :default

      # Public: Revokes the organization's granted authorizations created before
      # the given date, optionally limited to impersonated users only.
      #
      # organization      - The Decidim::Organization whose authorizations will be revoked.
      # current_user      - The Decidim::User performing the action (used for traceability).
      # before_date       - A Date or Time; only authorizations created before it are revoked.
      # impersonated_only - Boolean; when true, only impersonated users' authorizations are revoked.
      #
      # Returns nothing.
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
