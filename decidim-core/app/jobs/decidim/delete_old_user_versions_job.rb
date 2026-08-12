# frozen_string_literal: true

module Decidim
  # A job to delete version data for old deleted users.
  class DeleteOldUserVersionsJob < DeleteOldVersionsJob
    queue_as :delete_old_personal_data_versions

    item_type "Decidim::UserBaseEntity"

    private

    # Include only deleted users.
    def include_records
      Decidim::User.where.not(deleted_at: nil)
    end
  end
end
