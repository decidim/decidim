# frozen_string_literal: true
module Decidim
  module Admin
    # A form object to create or update pages.
    class StaticPageForm < Form
      include TranslatableAttributes

      attribute :slug, String
      attribute :organization, Decidim::Organization
      translatable_attribute :title, String
      translatable_attribute :content, String

      mimic :static_page

      validates :slug, :organization, presence: true
      translatable_validates :title, :content, presence: true
      validate :slug, :slug_uniqueness

      private

      def slug_uniqueness
        return unless organization && organization.static_pages.where(slug: slug).where.not(id: id).any?

        errors.add(:slug, :taken)
      end
    end
  end
end
