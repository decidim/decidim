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
      organization.users
                  .not_deleted
                  .where("extended_data ? 'inactivity_notification'")
                  .where("current_sign_in_at > (extended_data->'inactivity_notification'->>'sent_at')::timestamp")
                  .find_each do |user|
        user.transaction do
          user.extended_data.delete("inactivity_notification")
          user.save!
        end
      end
    end

    def send_first_warning_notifications(users)
      process_users(users) do |user|
        user.update!(
          extended_data: user.extended_data.merge(
            "inactivity_notification" => { "type" => "first", "sent_at" => Time.current }
          )
        )
        send_notification(user, :inactivity_first_warning)
      end
    end

    def send_last_warning_notifications(users)
      process_users(users) do |user|
        user.update!(
          extended_data: user.extended_data.merge(
            "inactivity_notification" => { "type" => "second", "sent_at" => Time.current }
          )
        )
        send_notification(user, :inactivity_final_warning)
      end
    end

    def remove_inactive_users(users)
      process_users(users) do |user|
        send_notification(user, :removal_notification)
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

    def send_notification(user, mailer_method)
      ParticipantsAccountMailer.public_send(mailer_method, user).deliver_later
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
