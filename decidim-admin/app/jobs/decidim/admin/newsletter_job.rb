# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class NewsletterJob < ApplicationJob
      queue_as :newsletter

      def perform(newsletter)
        @newsletter = newsletter

        @newsletter.with_lock do
          raise "Newsletter already sent" if @newsletter.sent?

          @newsletter.update!(
            sent_at: Time.current,
            total_recipients: recipients.count,
            total_deliveries: 0
          )
        end

        recipients.find_each do |user|
          NewsletterDeliveryJob.perform_later(user, @newsletter)
        end
      end

      private

      def recipients
        @recipients ||= User.where(organization: @newsletter.organization)
                            .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)
                            .not_deleted
      end
    end
  end
end
