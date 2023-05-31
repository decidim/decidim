# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # This mailer sends a notification email containing the export as an
      # attachment.
      class ExportMailer < Decidim::ApplicationMailer
        include TranslatableAttributes
        # Public: Sends a notification email with a link to retrieve
        # the result of a access codes export in a zipped file.
        #
        # user - The user to be notified.
        #
        # Returns nothing.
        def access_codes_export(user, voting, filename, password)
          @password = password
          @user = user
          @organization = user.organization
          @file_url = export_file_url(user, voting, filename)

          with_user(user) do
            mail(
              to: "#{user.name} <#{user.email}>",
              subject: I18n.t("export_mailer.access_codes_export.subject", scope: "decidim.votings.census", voting_title: translated_attribute(voting.title))
            )
          end
        end

        private

        def export_file_url(user, voting, filename)
          Decidim::Votings::AdminEngine
            .routes
            .url_helpers.download_access_codes_file_voting_census_url(
              host: user.organization.host,
              voting_slug: voting.slug,
              filename:
            )
        end
      end
    end
  end
end
