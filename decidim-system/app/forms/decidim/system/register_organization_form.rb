# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class RegisterOrganizationForm < BaseOrganizationForm
      include JsonbAttributes
      mimic :organization

      attribute :name, String

      attribute :organization_admin_email, String
      attribute :organization_admin_name, String
      attribute :available_locales, Array
      attribute :default_locale, String
      attribute :reference_prefix
      attribute :users_registration_mode, String
      attribute :force_users_to_authenticate_before_access_organization, Boolean

      validates :organization_admin_email, :organization_admin_name, :name, :reference_prefix, presence: true
      validates :name, presence: true
      validates :available_locales, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }

      private

      def validate_organization_uniqueness
        base_query = Decidim::Organization.pluck(:name)

        organization_names = []

        base_query.each do |value|
          organization_names += value.except("machine_translations").values
          organization_names += value.fetch("machine_translations", {}).values
        end

        organization_names = organization_names.map(&:downcase)

        errors.add(:name, :taken) if organization_names.include?(name&.downcase)
        errors.add(:host, :taken) if Decidim::Organization.where(host:).where.not(id:).exists?
      end
    end
  end
end
