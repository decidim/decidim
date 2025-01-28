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
        .where("last_sign_in_at IS NULL OR last_sign_in_at < ?", Time.current - (@inactivity_period_days - @initial_warning_period_days).days)
        .where(marked_for_deletion_at: nil)
    end

    def users_to_send_reminder
      base_query
        .marked_for_deletion
        .where(marked_for_deletion_at: ..(Time.current - (@initial_warning_period_days - @final_reminder_period_days).days))
        .where(last_sign_in_at: ...(Time.current - (@inactivity_period_days - @final_reminder_period_days).days))
    end

    def users_to_remove
      base_query
        .marked_for_deletion
        .where(marked_for_deletion_at: ..(Time.current - @initial_warning_period_days.days))
        .where(last_sign_in_at: ..(Time.current - @inactivity_period_days.days))
    end

    def users_to_unmark_for_deletion
      base_query
        .where.not(marked_for_deletion_at: nil)
        .where("last_sign_in_at > marked_for_deletion_at")
    end

    private

    attr_reader :organization

    def base_query
      Decidim::User.unscoped
                   .where(organization:)
                   .where(created_at: ...(Time.current - @inactivity_period_days.days))
                   .not_deleted
                   .where.not(email: "")
    end
  end
end
