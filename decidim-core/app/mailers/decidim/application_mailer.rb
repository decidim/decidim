# frozen_string_literal: true

module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include LocalisedMailer
    include MultitenantAssetHost
    include Decidim::SanitizeHelper
    include Decidim::OrganizationHelper
    helper_method :organization_name, :current_locale, :decidim_escape_translated, :decidim_sanitize_translated, :translated_attribute, :decidim_sanitize,
                  :decidim_sanitize_newsletter

    after_action :set_smtp
    after_action :set_from

    default from: Decidim.config.mailer_sender
    layout "decidim/mailer"

    private

    attr_reader :organization

    def current_locale
      I18n.locale || I18n.default_locale
    end

    def set_smtp
      return if organization.nil? || organization.smtp_settings.blank? || organization.smtp_settings.except("from", "from_label", "from_email").all?(&:blank?)

      mail.reply_to = mail.reply_to || Decidim.config.mailer_reply
      mail.delivery_method.settings.merge!(
        address: organization.smtp_settings["address"],
        port: organization.smtp_settings["port"],
        user_name: organization.smtp_settings["user_name"],
        password: Decidim::AttributeEncryptor.decrypt(organization.smtp_settings["encrypted_password"])
      ) { |_k, o, v| v.presence || o }.compact_blank!
    end

    def set_from
      return if organization.nil?
      return if already_defined_name_in_mail?(mail.from.first)

      mail.from = sender
    end

    def sender
      return Decidim.config.mailer_sender if return_mailer_sender?
      return default_sender if organization.smtp_settings.blank?
      return default_sender if organization.smtp_settings["from"].nil?
      return default_sender if organization.smtp_settings["from"].empty?

      smtp_settings_from = organization.smtp_settings["from"]
      return smtp_settings_from if already_defined_name_in_mail?(smtp_settings_from)

      email_address_with_name(smtp_settings_from, organization_name(organization))
    end

    def default_sender
      email_address_with_name(Decidim.config.mailer_sender, organization_name(organization))
    end

    def already_defined_name_in_mail?(mail_address)
      # if there is an space, there is already a name in the address
      mail_address.match?(/ /)
    end

    def return_mailer_sender?
      already_defined_name_in_mail?(Decidim.config.mailer_sender) && organization.smtp_settings.present?
    end
  end
end
