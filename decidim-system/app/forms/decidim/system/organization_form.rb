# frozen_string_literal: true
module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class OrganizationForm < Rectify::Form
      mimic :organization

      attribute :name, String
      attribute :host, String
      attribute :organization_admin_email, String

      validates :name, :host, :organization_admin_email, presence: true
      validate :validate_organization_uniqueness

      private

      def validate_organization_uniqueness
        Decidim::Organization.where(name: name).or(Decidim::Organization.where(host: host)).exists?
      end
    end
  end
end
