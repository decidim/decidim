# frozen_string_literal: true

namespace :decidim do
  namespace :attachments do
    desc "Cleanup the orphaned blobs attachments"
    task cleanup: :environment do
      return if Decidim.clean_up_unattached_blobs_after.to_i.zero?

      ActiveStorage::Blob.unattached.where(created_at: ..Decidim.clean_up_unattached_blobs_after.ago).find_each(batch_size: 100, &:purge_later)
    end
  end
end
