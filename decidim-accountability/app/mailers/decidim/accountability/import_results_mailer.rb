# frozen_string_literal: true

module Decidim
  module Accountability
    # This mailer sends a notification email containing the result of importing
    # results from one component to accountability.
    class ImportResultsMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      helper Decidim::TranslationsHelper

      # Public: Sends a notification email with the result of importing results
      #
      # user   - The user to be notified.
      #
      # Returns nothing.
      def import(user, component, projects)
        @user = user
        @organization = user.organization
        @component = component
        @projects = projects

        with_user(user) do
          mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.accountability.import_results_mailer.import.subject"))
        end
      end
    end
  end
end
