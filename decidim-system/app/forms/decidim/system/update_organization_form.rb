# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to update organizations from the system dashboard.
    #
    class UpdateOrganizationForm < Form
      include TranslatableAttributes
      include JsonbAttributes

      mimic :organization

      attribute :name, String
      attribute :host, String
      attribute :secondary_hosts, String
      attribute :force_users_to_authenticate_before_access_organization, Boolean
      attribute :available_authorizations, Array[String]
      attribute :users_registration_mode, String
      jsonb_attribute :smtp_settings, [
        [:from, String],
        [:from_email, String],
        [:from_label, String],
        [:user_name, String],
        [:encrypted_password, String],
        [:address, String],
        [:port, Integer],
        [:authentication, String],
        [:enable_starttls_auto, Boolean]
      ]

      jsonb_attribute :content_security_policy, [
        [:"default-src", String],
        [:"img-src", String],
        [:"media-src", String],
        [:"script-src", String],
        [:"style-src", String],
        [:"frame-src", String],
        [:"font-src", String],
        [:"connect-src", String]
      ]

      attribute :password, String
      attribute :file_upload_settings, FileUploadSettingsForm

      OMNIATH_PROVIDERS_ATTRIBUTES = Decidim::OmniauthProvider.available.keys.map do |provider|
        Rails.application.secrets.dig(:omniauth, provider).keys.map do |setting|
          if setting == :enabled
            ["omniauth_settings_#{provider}_enabled".to_sym, Boolean]
          else
            ["omniauth_settings_#{provider}_#{setting}".to_sym, String]
          end
        end
      end.flatten(1)

      jsonb_attribute :omniauth_settings, OMNIATH_PROVIDERS_ATTRIBUTES

      validates :name, :host, :users_registration_mode, presence: true
      validate :validate_organization_uniqueness
      validate :validate_secret_key_base_for_encryption
      validates :users_registration_mode, inclusion: { in: Decidim::Organization.users_registration_modes }

      def map_model(model)
        self.secondary_hosts = model.secondary_hosts.join("\n")
        self.omniauth_settings = (model.omniauth_settings || {}).transform_values do |v|
          Decidim::OmniauthProvider.value_defined?(v) ? Decidim::AttributeEncryptor.decrypt(v) : v
        end
        self.file_upload_settings = FileUploadSettingsForm.from_model(model.file_upload_settings)
      end

      def clean_secondary_hosts
        return unless secondary_hosts

        secondary_hosts.split("\n").map(&:chomp).select(&:present?)
      end

      def clean_available_authorizations
        return unless available_authorizations

        available_authorizations.select(&:present?)
      end

      def password
        encrypted_password.nil? ? super : Decidim::AttributeEncryptor.decrypt(encrypted_password)
      end

      def encrypted_smtp_settings
        smtp_settings["from"] = set_from

        encrypted = smtp_settings.merge(encrypted_password: Decidim::AttributeEncryptor.encrypt(password))

        # if all are empty, nil is returned so it does not break ENV vars configuration
        encrypted.values.all?(&:blank?) ? nil : encrypted
      end

      def set_from
        return from_email if from_label.blank?

        "#{from_label} <#{from_email}>"
      end

      def encrypted_omniauth_settings
        encrypted = omniauth_settings.transform_values do |v|
          Decidim::OmniauthProvider.value_defined?(v) ? Decidim::AttributeEncryptor.encrypt(v) : v
        end

        # if all are empty, nil is returned so it does not break ENV vars configuration
        encrypted.values.all?(&:blank?) ? nil : encrypted
      end

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name:).where.not(id:).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host:).where.not(id:).exists?
      end

      # We need a valid secret key base for encrypting the SMTP password with it
      # It is also necessary for other things in Rails (like Cookies encryption)
      def validate_secret_key_base_for_encryption
        return if Rails.application.secrets.secret_key_base&.length == 128

        errors.add(:password, I18n.t("activemodel.errors.models.organization.attributes.password.secret_key"))
      end
    end
  end
end
