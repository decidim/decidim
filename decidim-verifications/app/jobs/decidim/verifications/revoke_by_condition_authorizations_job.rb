# frozen_string_literal: true

module Decidim
  module Verifications
    class RevokeByConditionAuthorizationsJob < Decidim::ApplicationJob
      queue_as :default

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

        auths = authorizations_to_revoke.query.includes(:transfers)
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
