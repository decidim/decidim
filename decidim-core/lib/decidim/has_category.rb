# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a category.
  module HasCategory
    extend ActiveSupport::Concern

    included do
      has_one :categorization, as: :categorizable
      has_one :category, through: :categorization

      validate :category_belongs_to_organization

      def previous_category
        return if self.categorization.versions.count <= 1
        category_id = self.categorization.paper_trail.previous_version.decidim_category_id
        Decidim::Category.find_by_id category_id
      end

      private

      def category_belongs_to_organization
        return unless category
        errors.add(:category, :invalid) unless feature.categories.where(id: category.id).exists?
      end
    end
  end
end
