# frozen_string_literal: true

module Decidim
  # Store user's social identities
  class Identity < ApplicationRecord
    belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::User"
    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

    validates :user, presence: true
    validates :provider, presence: true
    validates :uid, presence: true, uniqueness: { scope: [:provider, :organization] }

    validate :same_organization

    private

    def same_organization
      return if organization == user&.organization
      errors.add(:organization, :invalid)
    end
  end
end
