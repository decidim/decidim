# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to update organizations from the system dashboard.
    #
    class UpdateOrganizationForm < BaseOrganizationForm
      translatable_attribute :name, String

      validate :validate_organization_name_presence

      private

      def validate_organization_name_presence
        translated_attr = "name_#{current_organization.try(:default_locale) || Decidim.default_locale.to_s}".to_sym
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

          errors.add("name_#{language}", :taken) if organization_names.include?(value.downcase)
        end

        errors.add(:host, :taken) if Decidim::Organization.where(host:).where.not(id:).exists?
      end
    end
  end
end
