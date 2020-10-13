# frozen_string_literal: true

class UpdateSmtpFromLabel < ActiveRecord::Migration[5.2]
  def change
    Decidim::Organization.all.each do |org|
      if org.smtp_settings[:from_email].blank?
        org.smtp_settings[:from_email] = org.smtp_settings[:from]
        org.save!
      end
    end
  end
end
