# frozen_string_literal: true

namespace :decidim do
  namespace :verifications do
    namespace :revoke do
      Decidim.authorization_engines.pluck(:name).each do |authorization|
        desc "Revokes authorizations for the #{authorization} workflow"
        task authorization, [] => :environment do
          logger.info("=== Revoking authorizations for the #{authorization} workflow")
          Decidim::Authorization.where(name: authorization).destroy_all
          logger.info("===== Done")
        end
      end
    end
  end
end
