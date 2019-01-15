# frozen_string_literal: true

module Decidim
  # This mailer sends a notification email containing the export as an
  # attachment.
  class ExportMailer < ApplicationMailer
    # TODO: REMOVE the "default from: Decidim.config.mailer_sender"
    # The :from should've been inherited from ApplicationMailer
    # For an unknown reason, it doesn't
    default from: Decidim.config.mailer_sender

    # Public: Sends a notification email with the result of an export in a
    # zipped file.
    #
    # user        - The user to be notified.
    # export_name - The name of the export.
    # export_data - The data containing the result of the export.
    #
    # Returns nothing.
    def export(user, export_name, export_data)
      @user = user
      @organization = user.organization

      filename = export_data.filename(export_name)
      filename_without_extension = export_data.filename(export_name, extension: false)

      attachments["#{filename_without_extension}.zip"] = FileZipper.new(filename, export_data.read).zip

      with_user(user) do
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject", name: filename))
      end
    end

    def data_portability_export(user, export_data, export_images)
      @user = user
      @organization = user.organization

      file_zipper = Decidim::DataPortabilityFileZipper.new(@user, export_data, export_images)
      file_zipper.make_zip

      with_user(user) do
        @token = file_zipper.token
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject", name: user.name))
      end
    end
  end
end
