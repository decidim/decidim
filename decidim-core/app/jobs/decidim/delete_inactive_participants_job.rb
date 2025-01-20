# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    DELETE_PERIOD = 30.days.freeze
    REMINDER_PERIOD = 7.days.freeze

    def perform(organization)
      assign_removal_dates(organization)

      [DELETE_PERIOD, REMINDER_PERIOD].each do |period|
        notify_users(users_to_notify(organization, period), period)
      end

      remove_inactive_users(users_to_remove(organization))
    end

    private

    def scoped_users(organization)
      Decidim::User.unscoped
                   .where(organization:)
                   .not_deleted
                   .where.not(email: "")
    end

    def assign_removal_dates(organization)
      scoped_users(organization)
        .where(removal_date: nil)
        .where(last_sign_in_at: ...(Time.zone.now - DELETE_PERIOD))
        .find_each do |user|
        user.update!(removal_date: Time.zone.now + DELETE_PERIOD)
        send_inactivity_notification(user, DELETE_PERIOD)
        Rails.logger.info "Assigned removal date and sent 30-day notification to #{user.email}"
      end
    end

    def users_to_notify(organization, period)
      scoped_users(organization)
        .where.not(removal_date: nil)
        .where(removal_date: ..(Time.zone.now + period))
        .where("last_inactivity_notice_sent_at IS NULL OR last_inactivity_notice_sent_at < ?", Time.zone.now - period)
    end

    def users_to_remove(organization)
      Decidim::User.unscoped
                   .where(organization:)
                   .not_deleted
                   .where.not(email: "")
                   .where(removal_date: ..Time.zone.now)
    end

    def notify_users(users, period)
      users.find_each do |user|
        send_inactivity_notification(user, period)
        update_notification_timestamp(user)
      rescue StandardError => e
        Rails.logger.error "Failed to send inactivity notification to #{user.email}: #{e.message}"
      else
        Rails.logger.info "Inactivity notification for #{period / 1.day} days sent to #{user.email}"
      end
    end

    def remove_inactive_users(users)
      users.find_each do |user|
        send_removal_notification(user)
        delete_user_account(user)
      end
    end

    def send_inactivity_notification(user, period)
      ParticipantsAccountMailer.inactivity_notification(user, period / 1.day).deliver_now
    end

    def send_removal_notification(user)
      ParticipantsAccountMailer.removal_notification(user).deliver_later
    rescue StandardError => e
      Rails.logger.error "Failed to enqueue removal notification for #{user.email}: #{e.message}"
    else
      Rails.logger.info "Enqueued removal notification for #{user.email}"
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          { delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period: Decidim.inactivity_period) }
        ).with_context({ current_user: user })
      )
    end

    def update_notification_timestamp(user)
      user.update!(last_inactivity_notice_sent_at: Time.zone.now)
    end
  end
end
