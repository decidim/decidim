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

      attr_writer :password

      validates :name, :host, :users_registration_mode, presence: true
      validate :validate_organization_uniqueness
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
        Decidim::AttributeEncryptor.decrypt(encrypted_password) unless encrypted_password.nil?
      end

      def encrypted_smtp_settings
        smtp_settings["from"] = set_from

        smtp_settings.merge(encrypted_password: Decidim::AttributeEncryptor.encrypt(@password))
      end

      def set_from
        return from_email if from_label.blank?

        "#{from_label} <#{from_email}>"
      end

      def encrypted_omniauth_settings
        omniauth_settings.transform_values do |v|
          Decidim::OmniauthProvider.value_defined?(v) ? Decidim::AttributeEncryptor.encrypt(v) : v
        end
      end

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name:).where.not(id:).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host:).where.not(id:).exists?
      end
    end
  end
end
