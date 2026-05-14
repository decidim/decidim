# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeAllAuthorizationsJob < Decidim::ApplicationJob
      queue_as :default

      # Revokes every granted authorization for the given organization.
      #
      # @param organization [Decidim::Organization] The organization whose authorizations will be revoked
      # @param current_user [Decidim::User] the current user.
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
