module Decidim
  module Admin
    class DeliverNewsletter < Rectify::Command
      def initialize(newsletter)
        @newsletter = newsletter
      end

      def call
        @newsletter.with_lock do
          return broadcast(:invalid) if @newsletter.sent?
          send_newsletter!
        end

        broadcast(:ok, @newsletter)
      end

      private

      def send_newsletter!
        @newsletter.update_attributes!(
          sent_at: Time.current
        )
        NewsletterJob.perform_later(@newsletter)
      end
    end
  end
end
