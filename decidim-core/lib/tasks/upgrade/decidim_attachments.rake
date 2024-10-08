# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Cleanup the orphaned blobs attachments"
    task :attachments_cleanup, [:clean_up_unattached_blobs_after_in_minutes] => :environment do |_task, args|
      args.with_defaults(clean_up_unattached_blobs_after_in_minutes: 60)

      clean_up_unattached_blobs_after_in_minutes = args[:clean_up_unattached_blobs_after_in_minutes].to_i

      ActiveStorage::Blob.unattached.where(created_at: ..clean_up_unattached_blobs_after_in_minutes.minutes.ago).find_each(batch_size: 100, &:purge_later)
    end
  end
end
