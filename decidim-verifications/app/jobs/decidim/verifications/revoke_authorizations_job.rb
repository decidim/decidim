# frozen_string_literal: true

module Decidim
  module Verifications
    # Revokes the granted authorizations of a verification method, optionally
    # limited to impersonated users and/or those created before a date.
    class RevokeAuthorizationsJob < Decidim::ApplicationJob
      queue_as :default

      def perform(organization, current_user, name, impersonated_only, before_date)
        auths = Authorizations.new(
          organization:,
          name:,
          granted: true,
          impersonated_only:,
          before_date:
        ).query.includes(transfers: :records)

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
