# frozen_string_literal: true

module Decidim
  # A job to delete version data for revoked (i.e. deleted) authorizations.
  class DeleteRevokedAuthorizationsVersionsJob < DeleteOldVersionsJob
    queue_as :delete_old_personal_data_versions

    item_type "Decidim::Authorization"

    private

    # Exclude authorizations that still exist in the system.
    def exclude_records
      Decidim::Authorization.all
    end
  end
end
