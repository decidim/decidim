# frozen_string_literal: true

module Decidim
  module Admin
    # Delivers the newsletter to its recipients.
    class DeliverNewsletter < Decidim::Command
      # Initializes the command.
      #
      # newsletter - The newsletter to deliver.
      # form - A form object with the params.
      # user - the Decidim::User that delivers the newsletter
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @form = form
        @user = user
      end

      def call
        return broadcast(:invalid) if @form.send_to_all_users && !@user.admin?
        return broadcast(:invalid) unless @form.valid?
        return broadcast(:invalid) if @newsletter.sent?
        return broadcast(:no_recipients) if recipients.blank?

        @newsletter.with_lock do
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
          NewsletterJob.perform_later(@newsletter, @form.as_json, recipients.map(&:id))
        end
      end

      def recipients
        @recipients ||= Decidim::Admin::NewsletterRecipients.for(@form)
      end
    end
  end
end
