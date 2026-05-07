# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeAllAuthorizationsJob < Decidim::ApplicationJob
      queue_as :default

      def perform(organization, current_user)
        auths = Decidim::Verifications::Authorizations.new(
          organization:,
          granted: true
        ).query

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
