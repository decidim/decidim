# frozen_string_literal: true

module Decidim
  # This mailer sends a notification email containing the export as an
  # attachment.
  class ExportMailer < ApplicationMailer
    # Public: Sends a notification email with the result of an export in a
    # zipped file.
    #
    # user           - The user to be notified.
    # private_export - The private private_export where the export data has been attached.
    #
    # Returns nothing.
    def export(user, private_export)
      @user = user
      @organization = user.organization
      @private_export = private_export

      with_user(user) do
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject", name: private_export.export_type))
      end
    end

    # Public: Sends a notification email with a link to retrieve
    # the result of a download_your_data export in a zipped file.
    #
    # user - The user to be notified.
    # private_export - The private private_export where the export data has been attached.
    #
    # Returns nothing.
    def download_your_data_export(user, private_export)
      @user = user
      @organization = user.organization
      @private_export = private_export

      with_user(user) do
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject", name: user.name))
      end
    end
  end
end
