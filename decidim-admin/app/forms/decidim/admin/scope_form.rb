# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update scopes.
    class ScopeForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      attribute :organization, Decidim::Organization
      attribute :code, String
      attribute :parent_id, Integer
      attribute :scope_type_id, Integer
      attribute :deprecated, Boolean

      mimic :scope

      validates :name, translatable_presence: true
      validates :organization, :code, presence: true
      validate :code, :code_uniqueness

      alias organization current_organization

      private

      def code_uniqueness
        return unless organization && organization.scopes.where(code: code).where.not(id: id).any?

        errors.add(:code, :taken)
      end
    end
  end
end
