# frozen_string_literal: true

module Decidim
  # Query class to handle fetching users for the inactive participants job.
  # This class provides methods to retrieve specific groups of users based on their
  # activity status, removal date, and notification timestamps.
  class InactiveUsersQuery < Decidim::Query
    # Initializes the query with the necessary parameters.
    #
    # @param organization [Decidim::Organization] the organization to scope the query to.
    # @param reminder_period [ActiveSupport::Duration] the period before account deletion to send reminders.
    # @param inactivity_period [Integer] the number of days of inactivity before marking the user for deletion.
    def initialize(organization, reminder_period, inactivity_period)
      @organization = organization
      @reminder_period = reminder_period
      @inactivity_period = inactivity_period
    end

    # Finds users who logged in after receiving a removal date.
    def reset_inactivity_marks
      base_query
        .where.not(removal_date: nil)
        .where("last_sign_in_at > ?", @inactivity_period.days.ago)
    end

    # Finds users who are inactive and have no removal_date set.
    def inactive_users
      base_query
        .merge(Decidim::User.where(removal_date: nil))
        .where(created_at: ...@inactivity_period.days.ago)
        .where("last_sign_in_at < ? OR last_sign_in_at IS NULL", @inactivity_period.days.ago)
    end

    # Finds users who are scheduled for deletion and are due for a reminder notification.
    def users_for_reminder
      base_query
        .where.not(removal_date: nil)
        .where(removal_date: ..(@reminder_period.from_now))
        .where(last_inactivity_notice_sent_at: ...(@reminder_period.ago))
    end

    # Finds users who are ready for deletion based on their removal_date.
    def users_for_removal
      base_query
        .where.not(removal_date: nil)
        .where(removal_date: ..Time.zone.now)
    end

    private

    attr_reader :organization

    # Base query that scopes to the organization and filters out deleted users or users without email.
    def base_query
      Decidim::User.unscoped
                   .where(organization:)
                   .not_deleted
                   .where.not(email: "")
    end
  end
end
