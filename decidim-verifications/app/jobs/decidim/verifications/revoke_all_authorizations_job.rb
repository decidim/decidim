# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeAllAuthorizationsJob < Decidim::ApplicationJob
      queue_as :default

      # Public: Revokes every granted authorization for the given organization.
      #
      # organization - The Decidim::Organization whose authorizations will be revoked.
      # current_user - The Decidim::User performing the action (used for traceability).
      #
      # Returns nothing.
      def perform(organization, current_user)
        auths = Decidim::Verifications::Authorizations.new(
          organization:,
          granted: true
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
