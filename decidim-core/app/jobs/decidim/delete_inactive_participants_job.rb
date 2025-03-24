# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    def perform(organization)
      clear_notifications_for_active_users(organization)
      send_first_warning_notifications(organization.users.first_warning_inactive_users)
      send_last_warning_notifications(organization.users.last_warning_inactive_users)
      remove_inactive_users(organization.users.removable_users)
    end

    private

    def enqueue_jobs(users, action, *args)
      users.find_each do |user|
        ProcessInactiveParticipantJob.perform_later(user.id, action, *args)
      end
    end

    def clear_notifications_for_active_users(organization)
      enqueue_jobs(organization.users.not_deleted
                               .with_inactivity_notification
                               .active_after_notification, :clear_notification)
    end

    def send_first_warning_notifications(users)
      enqueue_jobs(users, :send_warning, "first", Decidim.delete_inactive_users_first_warning_days_before)
    end

    def send_last_warning_notifications(users)
      enqueue_jobs(users, :send_warning, "second", Decidim.delete_inactive_users_last_warning_days_before)
    end

    def remove_inactive_users(users)
      enqueue_jobs(users, :remove)
    end
  end
end
