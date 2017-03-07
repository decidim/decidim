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
      attribute :secondary_hosts, String

      validates :name, presence: true
      validates :host, presence: true
      validate :validate_organization_uniqueness

      def map_model(model)
        self.secondary_hosts = model.secondary_hosts.join("\n")
      end

      def clean_secondary_hosts
        return unless secondary_hosts
        secondary_hosts.split("\n").map(&:chomp).select(&:present?)
      end

      private

      def validate_organization_uniqueness
        errors.add(:name, :taken) if Decidim::Organization.where(name: name).where.not(id: id).exists?
        errors.add(:host, :taken) if Decidim::Organization.where(host: host).where.not(id: id).exists?
      end
    end
  end
end
