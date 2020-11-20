# frozen_string_literal: true

class FillSmtpFromEmail < ActiveRecord::Migration[5.2]
  def up
    Decidim::Organization.all.each do |org|
      if org.smtp_settings["from_email"].blank?
        org.smtp_settings["from_email"] = org.smtp_settings["from"]
        org.save!
      end
    end
  end
end
