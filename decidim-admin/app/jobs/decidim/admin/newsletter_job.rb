# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class NewsletterJob < ApplicationJob
      queue_as :newsletter
      self.enqueue_after_transaction_commit = :never

      def perform(newsletter, form, recipients_ids)
        @newsletter = newsletter
        @form = form
        @recipients_ids = recipients_ids

        @newsletter.with_lock do
          raise "Newsletter already sent" if @newsletter.sent?

          @newsletter.update!(
            sent_at: Time.current,
            extended_data:,
            total_recipients: recipients.count,
            total_deliveries: 0
          )
        end

        recipients.find_each do |user|
          NewsletterDeliveryJob.perform_later(user, @newsletter)
        end
      end

      private

      def extended_data
        {
          send_to_all_users: @form["send_to_all_users"],
          send_to_verified_users: @form["send_to_verified_users"],
          send_to_followers: @form["send_to_followers"],
          send_to_participants: @form["send_to_participants"],
          send_to_private_members: @form["send_to_private_members"],
          participatory_space_types: @form["participatory_space_types"],
          verification_types: @form["verification_types"]
        }
      end

      def recipients
        @recipients ||= User.where(organization: @newsletter.organization)
                            .where(id: @recipients_ids)
      end
    end
  end
end
