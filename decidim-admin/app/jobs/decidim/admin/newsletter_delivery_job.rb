# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class NewsletterDeliveryJob < ApplicationJob
      queue_as :newsletter

      def perform(user, newsletter)
        NewsletterMailer.newsletter(user, newsletter).deliver_now

        # rubocop:disable Rails/SkipsModelValidations
        newsletter.with_lock do
          newsletter.increment!(:total_deliveries)
        end
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
