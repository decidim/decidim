# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to update organizations from the system dashboard.
    #
    class UpdateOrganizationForm < BaseOrganizationForm
      translatable_attribute :name, String
      translatable_attribute :short_name, String

      attribute :two_factor_authentication_enabled, Boolean, default: false
      attribute :available_two_factor_methods, Array[String]

      validate :validate_organization_name_presence
      validate :validate_organization_short_name_presence
      validate :validate_short_name_format

      validates :available_two_factor_methods, presence: true, if: :two_factor_authentication_enabled
      validate :available_two_factor_methods_offered

      def map_model(model)
        super

        self.available_two_factor_methods = Decidim::TwoFactor.available_methods(model).map(&:name)
      end

      def available_two_factor_methods
        super.compact_blank
      end

      private

      def available_two_factor_methods_offered
        offered = Decidim::TwoFactor.available_methods.map(&:name)
        return if (available_two_factor_methods - offered).empty?

        errors.add(:available_two_factor_methods, :inclusion)
      end

      def validate_organization_name_presence
        translated_attr = :"name_#{current_organization.try(:default_locale) || Decidim.default_locale.to_s}"
        errors.add(translated_attr, :blank) if send(translated_attr).blank?
      end

      def validate_organization_short_name_presence
        translated_attr = :"short_name_#{current_organization.try(:default_locale) || Decidim.default_locale.to_s}"
        errors.add(translated_attr, :blank) if send(translated_attr).blank?
      end

      def validate_organization_uniqueness
        base_query = persisted? ? Decidim::Organization.where.not(id:).all : Decidim::Organization.all

        organization_names = []

        base_query.pluck(:name).each do |value|
          organization_names += value.except("machine_translations").values
          organization_names += value.fetch("machine_translations", {}).values
        end

        organization_names = organization_names.map(&:downcase).compact_blank

        name.each do |language, value|
          next if value.is_a?(Hash)

          errors.add("name_#{language}", :taken) if organization_names.include?(value&.downcase)
        end

        errors.add(:host, :taken) if Decidim::Organization.where(host:).where.not(id:).exists?
      end

      def validate_short_name_uniqueness
        base_query = persisted? ? Decidim::Organization.where.not(id:).all : Decidim::Organization.all

        organization_short_names = []

        base_query.pluck(:short_name).each do |value|
          organization_short_names += value.except("machine_translations").values
          organization_short_names += value.fetch("machine_translations", {}).values
        end

        organization_short_names = organization_short_names.map(&:downcase).compact_blank

        short_name.each do |language, value|
          next if value.is_a?(Hash)

          errors.add("short_name_#{language}", :taken) if organization_short_names.include?(value&.downcase)
        end
      end

      def validate_short_name_format
        short_name.each do |language, value|
          next if value.is_a?(Hash)
          next if value.blank?

          errors.add("short_name_#{language}", :too_short, count: 3) if value.length < 3
          errors.add("short_name_#{language}", :too_long, count: 12) if value.length > 12
        end
      end
    end
  end
end
