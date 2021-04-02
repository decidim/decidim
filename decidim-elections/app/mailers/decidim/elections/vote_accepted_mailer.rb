# frozen_string_literal: true

module Decidim
  module Elections
    # This mailer sends a notification email with the accepted vote information.
    class VoteAcceptedMailer < Decidim::ApplicationMailer
      include TranslatableAttributes

      # Public: Sends a notification email with the accepted vote information when there is no
      # user to notify.
      #
      # vote       - The vote to be notified.
      # verify_url - The url to verify the vote.
      # locale     - The locale that will be used for the email content (optional).
      #
      # Returns nothing.
      def notification(vote, verify_url, locale = nil)
        @vote = vote
        @verify_url = verify_url
        @election_name = translated_attribute(vote.election.title)
        @organization = vote.election.component.organization

        I18n.with_locale(locale || @organization.default_locale) do
          mail(to: vote.email, subject: I18n.t("votes.accepted_votes.email_subject", scope: "decidim.events.elections", resource_name: @election_name))
        end
      end
    end
  end
end
