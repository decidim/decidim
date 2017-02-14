# frozen_string_literal: true
module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class NewsletterJob < ApplicationJob
      queue_as :newsletter

      def perform(newsletter)
        newsletter.with_lock do
          newsletter.update_attribute(:total_recipients, recipients.count)
          newsletter.update_attribute(:total_deliveries, 0)

          recipients.find_each do |user|
            NewsletterDeliveryJob.perform_later(user, newsletter)
          end
        end
      end

      private

      def recipients
        @recipients ||= User.where(newsletter_notifications: true)
      end
    end
  end
end
