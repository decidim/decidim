# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to copy a conferences from the admin
      # dashboard.
      #
      class ConferenceCopyForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String

        mimic :conference

        attribute :slug, String
        attribute :copy_categories, Boolean
        attribute :copy_components, Boolean

        validates :slug, presence: true, format: { with: Decidim::Conference.slug_format }
        validates :title, translatable_presence: true
        validate :slug_uniqueness

        private

        def slug_uniqueness
          return unless OrganizationConferences.new(current_organization).query.where(slug:).where.not(id:).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
