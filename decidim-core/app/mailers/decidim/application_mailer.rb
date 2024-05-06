# frozen_string_literal: true

module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include LocalisedMailer
    include MultitenantAssetHost
    after_action :set_smtp
    after_action :set_from

    default from: Decidim.config.mailer_sender
    layout "decidim/mailer"

    private

    def set_from
      return if @organization.nil?
      return if mail.from.any?(/ /) # if there is an space, there is already a name in the address

      mail.from = email_address_with_name(mail.from.first, @organization.name)
    end

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
