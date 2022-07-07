# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have a category.
  module HasCategory
    extend ActiveSupport::Concern

    included do
      has_one :categorization, as: :categorizable
      has_one :category, through: :categorization

      scope :with_category, lambda { |category|
        return includes(:category).where(decidim_categories: { id: nil }) if category == "without" || category.nil?

        includes(:category).where(decidim_categories: { id: category }).or(
          includes(:category).where(decidim_categories: { parent_id: category })
        )
      }

      scope :with_any_category, lambda { |*categories|
        return self if categories.include?("all")

        parent_ids = categories.without("without")
        cat_ids = parent_ids.dup
        cat_ids.prepend(nil) if categories.include?("without")

        subquery = includes(:category).where(decidim_categories: { id: cat_ids })
        return subquery if parent_ids.none?

        subquery.or(
          includes(:category).where(decidim_categories: { parent_id: parent_ids })
        )
      }

      scope :with_any_global_category, lambda { |*categories|
        return self if categories.include?("all")

        cat_ids = categories.without("without")

        additional_ids = cat_ids.grep(/Decidim__/)
        additional_ids = additional_ids.map { |a| a.gsub("__", "::").gsub(/(\d+)/, '.\1').split(".") }
        additional_ids = additional_ids.map { |v| v.first.safe_constantize.send(:find, v.last.to_i).category_ids }
        additional_ids = additional_ids.flatten

        with_any_category(*(categories + additional_ids))
      }

      validate :category_belongs_to_organization

      def previous_category
        return if categorization.versions.count <= 1

        Decidim::Category.find_by(id: categorization.versions.last.reify.decidim_category_id)
      end

      private

      def category_belongs_to_organization
        return unless category

        errors.add(:category, :invalid) unless component.categories.exists?(id: category.id)
      end
    end
  end
end
