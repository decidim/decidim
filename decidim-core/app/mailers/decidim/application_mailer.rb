# frozen_string_literal: true

module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include LocalisedMailer
    include MultitenantAssetHost
    after_action :set_smtp

    default from: Decidim.config.mailer_sender
    layout "decidim/mailer"

    private

    def set_smtp
      return if @organization.nil? || @organization.smtp_settings.blank?

      mail.from = @organization.smtp_settings["from"].presence || mail.from
      mail.reply_to = mail.reply_to || Decidim.config.mailer_reply
      mail.delivery_method.settings.merge!(
        address: @organization.smtp_settings["address"],
        port: @organization.smtp_settings["port"],
        user_name: @organization.smtp_settings["user_name"],
        password: Decidim::AttributeEncryptor.decrypt(@organization.smtp_settings["encrypted_password"])
      ) { |_k, o, v| v.presence || o }.compact_blank!
    end
  end
end
