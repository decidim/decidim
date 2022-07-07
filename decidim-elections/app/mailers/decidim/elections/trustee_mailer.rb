# frozen_string_literal: true

module Decidim
  module Elections
    # This mailer sends a notification email to a recently added trustee
    class TrusteeMailer < Decidim::ApplicationMailer
      include TranslatableAttributes

      # Public: Sends an email to a trustee that just got added to a participatory space.
      #
      # user - The user to be notified
      # participatory_space - The participatory space where the trustee was added.
      # locale - The locale that will be used for the email content (optional).
      #
      # Returns nothing.
      def notification(user, participatory_space, locale = nil)
        @user = user
        @participatory_space = participatory_space
        @organization = user.organization

        I18n.with_locale(locale || @organization.default_locale) do
          @participatory_space_title = translated_attribute(participatory_space.title)
          mail(to: user.email, subject: I18n.t("subject", scope: "decidim.elections.admin.mailers.trustee_mailer", resource_name: @participatory_space_title))
        end
      end
    end
  end
end
