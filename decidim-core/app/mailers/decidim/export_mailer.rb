# frozen_string_literal: true
module Decidim
  # This mailer sends a notification email containing the export as an
  # attachment.
  class ExportMailer < ApplicationMailer
    # Public: Sends a notification email with the result of an export in a
    # zipped file.
    #
    # user        - The user to be notified.
    # name        - The name of the export.
    # export_data - The data containing the result of the export.
    #
    # Returns nothing.
    def export(user, name, export_data)
      @user = user
      @organization = user.organization

      attachments["#{name}.zip"] = FileZipper.new(
        "#{name}.#{export_data.extension}", export_data.read
      ).zip

      with_user(user) do
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject", name: name))
      end
    end
  end
end
