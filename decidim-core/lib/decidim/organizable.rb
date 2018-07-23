# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to the relation between components and organizations
  module Organizable
    extend ActiveSupport::Concern

    included do
      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

      validates :organization, presence: true

      before_validation :assign_organization
    end

    def assign_organization
      return if organization.present? || try(:participatory_space).blank?
      self.organization = participatory_space.organization
    end
  end
end
