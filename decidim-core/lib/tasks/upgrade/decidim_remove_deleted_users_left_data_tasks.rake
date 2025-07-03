# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Removes deleted users left behind data"
    task remove_deleted_users_left_data: :environment do
      logger.info("=== Removing left behind data by 'Decidim::DestroyAccount'")
      Decidim::User.where.not(deleted_at: nil).find_each do |deleted_user|
        Decidim::Authorization.where(decidim_user_id: deleted_user.id).find_each(&:destroy)
        Decidim::Follow.where(followable: deleted_user).find_each(&:destroy)
        Decidim::Follow.where(user: deleted_user).find_each(&:destroy)
        Decidim::ParticipatorySpacePrivateUser.where(user: deleted_user).find_each(&:destroy)

        Decidim.participatory_space_manifests.each do |space_manifest|
          space_manifest.invoke_on_destroy_account(deleted_user)
        end

        deleted_user.identities.find_each(&:destroy)
        deleted_user.versions.find_each(&:destroy)
        deleted_user.private_exports.find_each(&:destroy)
        deleted_user.access_grants.find_each(&:destroy)
        deleted_user.access_tokens.find_each(&:destroy)
        deleted_user.reminders.find_each(&:destroy)
        deleted_user.notifications.find_each(&:destroy)
      end
    end
  end
end
