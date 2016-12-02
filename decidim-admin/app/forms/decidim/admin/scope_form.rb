# frozen_string_literal: true
module Decidim
  module Admin
    # A form object to create or update scopes.
    class ScopeForm < Form
      attribute :name, String
      attribute :organization, Decidim::Organization
      mimic :scope

      validates :name, :organization, presence: true
      validate :name, :name_uniqueness

      alias organization current_organization

      private

      def name_uniqueness
        return unless organization && organization.scopes.where(name: name).where.not(id: id).any?

        errors.add(:name, :taken)
      end
    end
  end
end
