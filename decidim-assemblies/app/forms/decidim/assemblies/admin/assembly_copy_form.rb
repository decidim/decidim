# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to copy a assemblies from the admin
      # dashboard.
      #
      class AssemblyCopyForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String

        mimic :assembly

        attribute :slug, String
        attribute :copy_components, Boolean
        attribute :copy_landing_page_blocks, Boolean

        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }
        validates :title, translatable_presence: true
        validate :slug_uniqueness

        private

        def slug_uniqueness
          return unless OrganizationAssemblies.new(current_organization).query.where(slug:).where.not(id:).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
