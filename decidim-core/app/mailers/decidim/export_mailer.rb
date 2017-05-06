# frozen_string_literal: true
module Decidim
  class ExportMailer < ApplicationMailer
    def export(user, scope, export_data)
      @user = user

      name = "#{scope}-#{I18n.localize(DateTime.now.to_date, format: :default)}-#{Time.now.seconds_since_midnight}"

      zip = Zip::OutputStream.write_buffer do |zipfile|
        zipfile.put_next_entry("#{name}.#{@export_data.extension}")
        zipfile.write @export_data.read
      end

      attachments[filename] = zip.string

      with_user(user) do
        mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.export_mailer.subject"))
      end
    end
  end
end
