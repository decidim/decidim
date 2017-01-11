# frozen_string_literal: true
module Decidim
  module Admin
    # A form object to create or update pages.
    class StaticPageForm < Form
      include TranslatableAttributes

      attribute :slug, String
      translatable_attribute :title, String
      translatable_attribute :content, String

      mimic :static_page

      validates :slug, presence: true
      validates :title, :content, translatable_presence: true
      validate :slug, :slug_uniqueness

      private

      def slug_uniqueness
        return unless current_organization && current_organization.static_pages.where(slug: slug).where.not(id: id).any?

        errors.add(:slug, :taken)
      end
    end
  end
end
