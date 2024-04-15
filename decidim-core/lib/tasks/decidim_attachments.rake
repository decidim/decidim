# frozen_string_literal: true

namespace :decidim do
  namespace :attachments do
    desc "Cleanup the orphaned blobs attachments"
    task cleanup: :environment do
      ActiveStorage::Blob.unattached.where(ActiveStorage::Blob.arel_table[:created_at].lteq(1.hour.ago)).find_each(&:purge_later)
    end
  end
end
