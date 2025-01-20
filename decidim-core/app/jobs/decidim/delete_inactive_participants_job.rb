# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    DELETE_PERIOD = 30.days.freeze
    REMINDER_PERIOD = 7.days.freeze

    def perform(organization)
      # Set removal dates for users who have been inactive for DELETE_PERIOD
      assign_removal_dates(organization)

      # Send first notifications to users
      notify_users(users_to_notify(organization, DELETE_PERIOD), DELETE_PERIOD)

      # Send second notifications to users
      notify_users(users_to_notify(organization, REMINDER_PERIOD), REMINDER_PERIOD)

      # Delete users with removal dates
      remove_inactive_users(users_to_remove(organization))
    end

    private

    # Set removal dates for users who have been inactive for DELETE_PERIOD
    def assign_removal_dates(organization)
      users = Decidim::User.unscoped
                           .where(organization:)
                           .not_deleted
                           .where.not(email: "")
                           .where(removal_date: nil)
                           .where(last_sign_in_at: ...(Time.zone.now - DELETE_PERIOD))

      users.find_each do |user|
        user.update!(removal_date: Time.zone.now + DELETE_PERIOD)
        send_inactivity_notification(user, DELETE_PERIOD)
        Rails.logger.info "Assigned removal date for #{user.email} and sent 30-day notification."
      end
    end

    # Find users to notify
    def users_to_notify(organization, period)
      Decidim::User.unscoped
                   .where(organization:)
                   .not_deleted
                   .where.not(email: "")
                   .where.not(removal_date: nil)
                   .where(removal_date: ..(Time.zone.now + period))
                   .where("last_inactivity_notice_sent_at IS NULL OR last_inactivity_notice_sent_at < ?", Time.zone.now - period)
    end

    # Find users to remove
    def users_to_remove(organization)
      Decidim::User.unscoped
                   .where(organization:)
                   .not_deleted
                   .where.not(email: "")
                   .where(removal_date: ..Time.zone.now)
    end

    def notify_users(users, period)
      days = period.to_i / 1.day
      users.find_each do |user|
        begin
          send_inactivity_notification(user, period)
          update_notification_timestamp(user)
          Rails.logger.info "Inactivity notification (#{days} days) sent to #{user.email}"
        rescue StandardError => e
          Rails.logger.error "Failed to send inactivity notification to #{user.email}: #{e.message}"
        end
      end
    end

    def remove_inactive_users(users)
      users.find_each do |user|
        send_removal_notification(user)
        delete_user_account(user)
      end
    end

    def send_inactivity_notification(user, period)
      days = period.to_i / 1.day
      ParticipantsAccountMailer.inactivity_notification(user, days).deliver_now
    end

    def send_removal_notification(user)
      Rails.logger.info "Removal notification sent to #{user.email}" if ParticipantsAccountMailer.removal_notification(user).deliver_later
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params({
                                                 delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period:)
                                               }).with_context({ current_user: user })
      )
      Rails.logger.info "Account for user with ID #{user.id} has been deleted."
    end

    def update_notification_timestamp(user)
      user.update!(last_inactivity_notice_sent_at: Time.zone.now)
    end
  end
end
