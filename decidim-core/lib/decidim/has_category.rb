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
        return if categorization.versions.count <= 1
        Decidim::Category.find_by(id: categorization.versions.last.reify.decidim_category_id)
      end

      private

      def category_belongs_to_organization
        return unless category
        errors.add(:category, :invalid) unless feature.categories.where(id: category.id).exists?
      end
    end
  end
end
