# frozen_string_literal: true

module Decidim
  module Accountability
    # This mailer sends a notification email containing the result of importing
    # proposals to the results.
    class ImportProposalsMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      helper Decidim::TranslationsHelper

      # Public: Sends a notification email with the result of proposals import selected proposals to Accountability
      #
      # user   - The user to be notified.
      #
      # Returns nothing.
      def import(user, component, proposals)
        @user = user
        @organization = user.organization
        @component = component
        @proposals = proposals

        with_user(user) do
          mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.accountability.import_proposals_mailer.import.subject"))
        end
      end
    end
  end
end
