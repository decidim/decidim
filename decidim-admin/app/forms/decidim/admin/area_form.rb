# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update areas.
    class AreaForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      attribute :organization, Decidim::Organization
      attribute :area_type_id, Integer

      mimic :area

      validates :name, translatable_presence: true
      validates :organization, presence: true

      validate :name_uniqueness

      def name_uniqueness
        return unless organization
        return unless organization.areas.where(name:, area_type:).where.not(id:).any?

        errors.add(:name, :taken)
      end

      alias organization current_organization

      def area_type
        Decidim::AreaType.find_by(id: area_type_id) if area_type_id
      end
    end
  end
end
