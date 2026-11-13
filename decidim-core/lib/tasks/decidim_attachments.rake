# frozen_string_literal: true

namespace :decidim do
  desc "Cleanup the orphaned blobs attachments"
  # Blobs which are not attached to any record are purged when they are older
  # than the given window (60 minutes by default). The short window is
  # intentional: it removes abandoned or potentially dangerous uploads as soon
  # as possible. Note that a file uploaded in a form which is still open (and
  # not yet submitted) is also unattached, so a submission done after the
  # window may lose that upload. The window is only the earliest time at which
  # a blob becomes eligible for deletion: the recommended cron runs hourly and
  # the deletions are queued with purge_later, so a file may still be available
  # well past the window and the exact deletion time is not guaranteed. If
  # that trade-off is not acceptable for your instance, increase the window
  # with the clean_up_unattached_blobs_after_in_minutes argument, for instance
  # `bundle exec rake decidim:attachments_cleanup[1440]` keeps unattached
  # blobs for at least 24 hours.
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
