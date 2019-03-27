# frozen_string_literal: true

module Decidim
  module Admin
    # Delivers the newsletter to its recipients.
    class DeliverNewsletter < Rectify::Command
      # Initializes the command.
      #
      # newsletter - The newsletter to deliver.
      # user - the Decidim::User that delivers the newsletter
      def initialize(newsletter, user)
        @newsletter = newsletter
        @form = form
        @user = user
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
        raise
        Decidim.traceability.perform_action!(
          "deliver",
          @newsletter,
          @user
        ) do
          NewsletterJob.perform_later(@newsletter, @form)
        end
      end
    end
  end
end
