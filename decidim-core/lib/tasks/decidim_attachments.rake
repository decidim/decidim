# frozen_string_literal: true

namespace :decidim do
  desc "Cleanup the orphaned blobs attachments"
  # Blobs are purged when unattached for longer than the given window (60 minutes by
  # default). The short window is intentional: it removes abandoned or potentially
  # dangerous uploads as soon as possible. Files uploaded in a form that is still open
  # are also unattached, so submissions done after the window lose that file. Increase
  # clean_up_unattached_blobs_after_in_minutes if that trade-off is not acceptable.
  task :attachments_cleanup, [:clean_up_unattached_blobs_after_in_minutes] => :environment do |_task, args|
    args.with_defaults(clean_up_unattached_blobs_after_in_minutes: 60)

    clean_up_unattached_blobs_after_in_minutes = args[:clean_up_unattached_blobs_after_in_minutes].to_s
    unless clean_up_unattached_blobs_after_in_minutes.match?(/\A\d+\z/)
      raise ArgumentError,
            "clean_up_unattached_blobs_after_in_minutes must be a non-negative integer, " \
            "got #{clean_up_unattached_blobs_after_in_minutes.inspect}"
    end

    ActiveStorage::Blob.unattached.where(created_at: ..clean_up_unattached_blobs_after_in_minutes.to_i.minutes.ago).find_each(batch_size: 100, &:purge_later)
  end
end
