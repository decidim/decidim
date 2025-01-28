# frozen_string_literal: true

module Decidim
  # Query class to handle fetching users for the inactive participants job.
  # This class provides methods to retrieve specific groups of users based on their
  # activity status, removal date, and notification timestamps.
  class InactiveUsersQuery < Decidim::Query
    def initialize(organization, inactivity_period_days, initial_warning_period_days, final_reminder_period_days)
      @organization = organization
      @inactivity_period_days = inactivity_period_days
      @initial_warning_period_days = initial_warning_period_days
      @final_reminder_period_days = final_reminder_period_days
    end

    def users_to_mark_for_deletion
      base_query
        .merge(users_never_logged_in.or(users_last_seen_before(inactivity_date)))
        .where(marked_for_deletion_at: nil)
    end

    def users_to_send_reminder
      base_query
        .marked_for_deletion
        .where(marked_for_deletion_at: ..reminder_date)
        .merge(users_last_seen_before(final_reminder_date))
    end

    def users_to_remove
      base_query
        .marked_for_deletion
        .where(marked_for_deletion_at: ..deletion_date)
        .merge(users_last_seen_before(full_inactivity_date))
    end

    def users_to_unmark_for_deletion
      base_query
        .where.not(marked_for_deletion_at: nil)
        .where("last_sign_in_at > marked_for_deletion_at")
    end

    private

    attr_reader :organization, :inactivity_period_days,
                :initial_warning_period_days, :final_reminder_period_days

    def base_query
      Decidim::User.unscoped
                   .where(organization:, created_at: ...(Time.current - inactivity_period_days.days))
                   .not_deleted
                   .where.not(email: "")
    end

    def users_never_logged_in
      Decidim::User.where(last_sign_in_at: nil)
    end

    def users_last_seen_before(date)
      Decidim::User.where(Decidim::User.arel_table[:last_sign_in_at].lt(date))
    end

    # Date for marking users as inactive.
    def inactivity_date
      (inactivity_period_days - initial_warning_period_days).days.ago
    end

    # Date for sending a final reminder notification.
    def final_reminder_date
      (inactivity_period_days - final_reminder_period_days).days.ago
    end

    # Date for sending a reminder notification.
    def reminder_date
      (initial_warning_period_days - final_reminder_period_days).days.ago
    end

    # Date for considering a user for deletion.
    def deletion_date
      initial_warning_period_days.days.ago
    end

    # Date for full inactivity period.
    def full_inactivity_date
      inactivity_period_days.days.ago
    end
  end
end
