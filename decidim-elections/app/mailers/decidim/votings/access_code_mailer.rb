# frozen_string_literal: true

module Decidim
  module Votings
    # This mailer sends the access code via email.
    class AccessCodeMailer < Decidim::ApplicationMailer
      include TranslatableAttributes

      # Public: Sends an email with the access code.
      #
      # datum - The datum with the access code
      # locale - The locale that will be used for the email content (optional).
      #
      # Returns nothing.
      def send_access_code(datum, locale = nil)
        @datum = datum
        @organization = datum.dataset.voting.organization
        @voting = translated_attribute(datum.dataset.voting.title)

        I18n.with_locale(locale || @organization.default_locale) do
          @access_code = datum.access_code

          subject = I18n.t(
            "send_access_code.subject",
            scope: "decidim.events.votings",
            voting: @voting
          )

          mail(to: datum.email, subject:)
        end
      end
    end
  end
end
