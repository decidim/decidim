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
      attribute :available_authorizations, Array[String]
      attribute :users_registration_mode, String
      jsonb_attribute :smtp_settings, [:from, :user_name, :encrypted_password, :address, :port]

      attr_writer :password

      validates :name, :host, :users_registration_mode, presence: true
      validate :validate_organization_uniqueness
      validates :users_registration_mode, inclusion: { in: Decidim::Organization.users_registration_modes }

      def map_model(model)
        self.secondary_hosts = model.secondary_hosts.join("\n")
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
        smtp_settings.merge(encrypted_password: Decidim::AttributeEncryptor.encrypt(@password))
      end

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name: name).where.not(id: id).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host: host).where.not(id: id).exists?
      end
    end
  end
end
