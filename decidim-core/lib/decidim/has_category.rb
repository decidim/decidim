# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be have a category.
  module HasCategory
    extend ActiveSupport::Concern

    included do
      belongs_to :category, foreign_key: "decidim_category_id", class_name: "Decidim::Category"
      validate :category_belongs_to_organization

      private

      def category_belongs_to_organization
        return unless category
        errors.add(:category, :invalid) unless feature.categories.where(id: category.id).exists?
      end
    end
  end
end
