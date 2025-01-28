# frozen_string_literal: true

module Decidim
  # A job to delete inactive participants and notify them
  class DeleteInactiveParticipantsJob < ApplicationJob
    queue_as :delete_inactive_participants

    INITIAL_WARNING_PERIOD_DAYS = 30
    FINAL_REMINDER_PERIOD_DAYS = 7

    def perform(organization)
      query = InactiveUsersQuery.new(
        organization,
        inactivity_period,
        INITIAL_WARNING_PERIOD_DAYS,
        FINAL_REMINDER_PERIOD_DAYS
      )

      unmark_active_users(query.users_to_unmark_for_deletion)
      mark_users_for_deletion(query.users_to_mark_for_deletion)
      send_reminder_notifications(query.users_to_send_reminder)
      remove_inactive_users(query.users_to_remove)
    end

    private

    def unmark_active_users(users)
      process_users(users) { |user| user.update!(marked_for_deletion_at: nil) }
    end

    def mark_users_for_deletion(users)
      process_users(users) do |user|
        send_notification(user, :inactivity_notification, INITIAL_WARNING_PERIOD_DAYS)
        user.update!(marked_for_deletion_at: Time.current)
      end
    end

    def send_reminder_notifications(users)
      process_users(users) do |user|
        send_notification(user, :inactivity_notification, FINAL_REMINDER_PERIOD_DAYS)
      end
    end

    def remove_inactive_users(users)
      process_users(users) do |user|
        next unless user.removable?(inactivity_period)

        send_notification(user, :removal_notification)
        delete_user_account(user)
      end
    end

    def process_users(users, &block)
      users.find_each do |user|
        user.transaction { block.call(user) }
      end
    end

    def send_notification(user, mailer_method, *)
      ParticipantsAccountMailer.public_send(mailer_method, user, *).deliver_later
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period: inactivity_period)
        ).with_context(current_user: user)
      )
    end

    def inactivity_period
      Decidim.inactivity_period_days
    end
  end
end
