# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    DELETE_PERIOD = 30.days.freeze
    REMINDER_PERIOD = 7.days.freeze

    def perform(organization)
      query = InactiveUsersQuery.new(organization, REMINDER_PERIOD, inactivity_period)

      reset_inactivity_marks(query.reset_inactivity_marks)
      assign_removal_dates(query.inactive_users)
      send_reminder_notifications(query.users_for_reminder)
      remove_inactive_users(query.users_for_removal)
    end

    private

    def reset_inactivity_marks(users)
      users.find_each do |user|
        user.transaction do
          user.update!(removal_date: nil, last_inactivity_notice_sent_at: nil)
        end
      end
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

    def send_notification(user, mailer_method, *args)
      ParticipantsAccountMailer.public_send(mailer_method, user, *args).deliver_later
    rescue StandardError => e
      Rails.logger.error "[DeleteInactiveParticipantsJob] Failed to send #{mailer_method} to user #{user.id} (#{user.email}): #{e.message}"
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          { delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period:) }
        ).with_context({ current_user: user })
      )
    end

    def inactivity_period
      Decidim.inactivity_period
    end
  end
end
