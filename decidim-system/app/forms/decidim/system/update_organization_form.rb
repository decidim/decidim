# frozen_string_literal: true
require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to update organizations from the system dashboard.
    #
    class UpdateOrganizationForm < Form
      include TranslatableAttributes

      mimic :organization

      attribute :name, String
      attribute :host, String

      translatable_attribute :description, String

      validate :validate_organization_uniqueness

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name: name).where.not(id: id).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host: host).where.not(id: id).exists?
      end
    end
  end
end
