# frozen_string_literal: true

namespace :decidim do
  namespace :attachmens do
    desc "Cleanup the orphaned blobs attachments"
    task cleanup: :environment do
      ActiveStorage::Blob.includes(:attachments).find_each do |blob|
        next if blob.attachments.any?

        blob.purge
      end
    end
  end
end
