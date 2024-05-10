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

    def set_smtp
      return if @organization.nil? || @organization.smtp_settings.blank?

      mail.reply_to = mail.reply_to || Decidim.config.mailer_reply
      mail.delivery_method.settings.merge!(
        address: @organization.smtp_settings["address"],
        port: @organization.smtp_settings["port"],
        user_name: @organization.smtp_settings["user_name"],
        password: Decidim::AttributeEncryptor.decrypt(@organization.smtp_settings["encrypted_password"])
      ) { |_k, o, v| v.presence || o }.compact_blank!
    end

    def set_from
      return if @organization.nil?
      return if already_defined_name_in_mail?(mail.from.first)

      mail.from = get_from(mail.from.first)
    end

    def get_from(from)
      return default_from(from) if @organization.smtp_settings.blank?
      return default_from(from) if @organization.smtp_settings["from"].nil?
      return default_from(from) if @organization.smtp_settings["from"].empty?

      smtp_settings_from = @organization.smtp_settings["from"]
      return smtp_settings_from if already_defined_name_in_mail?(smtp_settings_from)

      email_address_with_name(smtp_settings_from, @organization.name)
    end

    def default_from(from)
      email_address_with_name(from, @organization.name)
    end

    def already_defined_name_in_mail?(mail_address)
      # if there is an space, there is already a name in the address
      mail_address.match?(/ /)
    end
  end
end
