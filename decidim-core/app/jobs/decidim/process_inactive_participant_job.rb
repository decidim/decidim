# frozen_string_literal: true

module Decidim
  # A job to process a single inactive participant
  class ProcessInactiveParticipantJob < ApplicationJob
    queue_as :delete_inactive_participants

    def perform(user_id, action, *)
      user = Decidim::User.find_by(id: user_id)
      return unless user

      case action.to_sym
      when :clear_notification
        user.extended_data.delete("inactivity_notification")
        user.save!
      when :send_warning
        process_send_warning(user, *)
      when :remove
        process_remove_user(user)
      end
    end

    private

    def process_send_warning(user, type, days)
      user.extended_data.deep_merge!(
        "inactivity_notification" => { "notification_type" => type, "sent_at" => Time.current }
      )
      user.update!(extended_data: user.extended_data)
      ParticipantsAccountMailer.inactivity_notification(user, days).deliver_later
    end

    def process_remove_user(user)
      email = user.email
      name = user.name
      locale = user.locale
      organization = user.organization

      ParticipantsAccountMailer.removal_notification(email, name, locale, organization).deliver_later

      Decidim::DestroyAccount.call(
        Decidim::DeleteAccountForm.from_params(
          delete_reason: I18n.t("decidim.account.destroy.inactive_account_removal_reason", inactivity_period: Decidim.delete_inactive_users_after_days)
        ).with_context(current_user: user)
      )
    end
  end
end
