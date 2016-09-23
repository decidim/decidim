# frozen_string_literal: true
module Decidim
  module System
    # A form object used to update organizations from the system dashboard.
    #
    class UpdateOrganizationForm < Rectify::Form
      mimic :organization

      attribute :name, String
      attribute :host, String

      validate :validate_organization_uniqueness

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name: name).where.not(id: id).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host: host).where.not(id: id).exists?
      end
    end
  end
end
