# frozen_string_literal: true

module Decidim
  module Admin
    # Delivers the newsletter to its recipients.
    class DeliverNewsletter < Rectify::Command
      # Initializes the command.
      #
      # newsletter - The newsletter to deliver.
      # user - the Decidim::User that delivers the newsletter
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @form = form
        @user = user
      end

      def call
        @newsletter.with_lock do
          return broadcast(:invalid) unless @form.valid?
          return broadcast(:invalid) if @newsletter.sent?

          send_newsletter!
        end

        broadcast(:ok, @newsletter)
      end

      private

      attr_reader :form

      def send_newsletter!
        Decidim.traceability.perform_action!(
          "deliver",
          @newsletter,
          @user
        ) do
          NewsletterJob.perform_later(@newsletter, @form.to_json, recipients.pluck(:id))
        end
      end

      def recipients
        @recipients ||= Decidim::Admin::NewsletterRecipients.new(@newsletter, @form).query
        # @recipients ||= User.where(organization: @newsletter.organization)
        #                     .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)
        #                     .not_deleted
      end
    end
  end
end
