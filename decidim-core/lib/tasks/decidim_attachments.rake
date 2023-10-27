# frozen_string_literal: true

namespace :decidim do
  namespace :attachmens do
    desc "Cleanup the orphaned blobs attachments"
    task cleanup: :environment do
      ActiveStorage::Blob.unattached.find_each(&:purge_later)
    end
  end
end
