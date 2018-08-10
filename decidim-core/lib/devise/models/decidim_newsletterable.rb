# frozen_string_literal: true

module Devise
  module Models
    # Newsletterable adds all needed validations to acomplish GDPR standards
    # in newsletter notification mailing
    #
    # Validates that all users with notifications activated have Opt-in in
    # some time
    module DecidimNewsletterable
      GDPR_DATE = "2018-05-25 00:00 +02:00"

      def newsletter_opt_in_notify
        unless newsletter_opt_in_valid?
          set_newsletter_token!
          Decidim::NewslettersOptInJob.perform_later(self, newsletter_token)
        end
      end

      def newsletter_opt_in_validate
        set_newsletter_opt_in! if newsletter_notifications_at.blank?
      end

      protected

      # Checks if Opt-in is valid or not
      # An user with notifications activated, must have an Opt-in
      def newsletter_opt_in_valid?
        newsletter_notifications_at > Time.zone.parse(GDPR_DATE)
      end

      # Fill token value with some random value
      # Removes opt_int timestamp
      # Deactivate newsletter notifications
      def set_newsletter_token
        self.newsletter_notifications_at = nil
        self.newsletter_token = SecureRandom.base58(24)
      end

      # Sets token and Opt-in values & saves
      def set_newsletter_token!
        set_newsletter_token
        save
      end

      # Fill Opt-in value with current time &
      # removes any token involved
      def set_newsletter_opt_in
        self.newsletter_notifications_at = Time.current
        self.newsletter_token = ""
      end

      # Sets Opt-in and token values & saves
      def set_newsletter_opt_in!
        set_newsletter_opt_in
        save
      end
    end
  end
end
