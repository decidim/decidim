# frozen_string_literal: true

module Decidim
  module Admin
    # Delivers the newsletter to its recipients.
    class DeliverNewsletter < Rectify::Command
      # Initializes the command.
      #
      # newsletter - The newsletter to deliver.
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
        NewsletterJob.perform_later(@newsletter)
      end
    end
  end
end
