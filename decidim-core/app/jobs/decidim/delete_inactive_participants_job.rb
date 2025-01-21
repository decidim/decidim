# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    DELETE_PERIOD = 30.days.freeze
    REMINDER_PERIOD = 7.days.freeze

    def perform(organization)
      inactive_users = fetch_inactive_users(organization)
      assign_removal_dates(inactive_users)

      reminder_users = fetch_users_for_reminder(organization)
      send_reminder_notifications(reminder_users)

      removal_users = fetch_users_for_removal(organization)
      remove_inactive_users(removal_users)
    end

    private

    def fetch_inactive_users(organization)
      Decidim::User.unscoped
                   .where(organization: organization)
                   .not_deleted
                   .where.not(email: "")
                   .where(created_at: ...(Decidim.inactivity_period.days.ago))
                   .where(removal_date: nil)
                   .where("last_sign_in_at < ? OR last_sign_in_at IS NULL", Decidim.inactivity_period.days.ago)
    end

    def fetch_users_for_reminder(organization)
      Decidim::User.unscoped
                   .where(organization: organization)
                   .not_deleted
                   .where.not(email: "")
                   .where.not(removal_date: nil)
                   .where(removal_date: ..(REMINDER_PERIOD.from_now))
                   .where(last_inactivity_notice_sent_at: ...(REMINDER_PERIOD.ago))
    end

    def fetch_users_for_removal(organization)
      Decidim::User.unscoped
                   .where(organization: organization)
                   .not_deleted
                   .where.not(email: "")
                   .where(removal_date: ..Time.zone.now)
    end

    def assign_removal_dates(users)
      users.find_each do |user|
        user.transaction do
          user.update!(removal_date: DELETE_PERIOD.from_now, last_inactivity_notice_sent_at: Time.zone.now)
          send_notification(user, :inactivity_notification, DELETE_PERIOD / 1.day)
        end
      end
    end

    def send_reminder_notifications(users)
      users.find_each do |user|
        user.transaction do
          send_notification(user, :inactivity_notification, REMINDER_PERIOD / 1.day)
          user.update!(last_inactivity_notice_sent_at: Time.zone.now)
        end
      end
    end

    def remove_inactive_users(users)
      users.find_each do |user|
        user.transaction do
          send_notification(user, :removal_notification)
          delete_user_account(user)
        end
      end
    end

    def send_notification(user, mailer_method, *)
      ParticipantsAccountMailer.public_send(mailer_method, user, *).deliver_later
    rescue StandardError => e
      Rails.logger.error "[DeleteInactiveParticipantsJob] Failed to send #{mailer_method} to user #{user.id} (#{user.email}): #{e.message}"
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          { delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period: Decidim.inactivity_period) }
        ).with_context({ current_user: user })
      )
    end
  end
end
