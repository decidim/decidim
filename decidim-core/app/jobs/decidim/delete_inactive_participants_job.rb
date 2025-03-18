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

    def clear_notifications_for_active_users(organization)
      process_users(organization.users.not_deleted
                                .with_inactivity_notification
                                .active_after_notification) do |user|
        user.extended_data.delete("inactivity_notification")
        user.save!
      end
    end

    def send_first_warning_notifications(users)
      send_warning_notification(users, "first", Decidim.delete_inactive_users_first_warning_days_before)
    end

    def send_last_warning_notifications(users)
      send_warning_notification(users, "second", Decidim.delete_inactive_users_last_warning_days_before)
    end

    def send_warning_notification(users, type, days)
      process_users(users) do |user|
        user.update!(
          extended_data: user.extended_data.deep_merge!(
            "inactivity_notification" => {
              "notification_type" => type,
              "sent_at" => Time.current
            }
          )
        )
        send_notification(user, :inactivity_notification, days)
      end
    end

    def remove_inactive_users(users)
      process_users(users) do |user|
        send_notification(user, :removal_notification, user.email, user.name, user.locale, user.organization)
        delete_user_account(user)
      end
    end

    def process_users(users, &block)
      users.find_each do |user|
        user.transaction do
          block.call(user)
        end
      end
    end

    def send_notification(user, mailer_method, *)
      case mailer_method
      when :removal_notification
        ParticipantsAccountMailer.public_send(mailer_method, *).deliver_later
      else
        ParticipantsAccountMailer.public_send(mailer_method, user, *).deliver_later
      end
    end

    def delete_user_account(user)
      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period: Decidim.delete_inactive_users_after_days)
        ).with_context(current_user: user)
      )
    end
  end
end
