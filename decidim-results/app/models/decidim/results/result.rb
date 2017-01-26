# frozen_string_literal: true
module Decidim
  module Results
    # The data store for a Result in the Decidim::Results component. It stores a
    # title, description and any other useful information to render a custom result.
    class Result < Results::ApplicationRecord
      include Decidim::Resourceable

      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      belongs_to :scope, foreign_key: "decidim_scope_id", class_name: Decidim::Scope
      belongs_to :category, foreign_key: "decidim_category_id", class_name: Decidim::Category
      has_one :organization, through: :feature

      validate :scope_belongs_to_organization
      validate :category_belongs_to_organization
      validates :feature, presence: true

      private

      def scope_belongs_to_organization
        return unless feature
        return unless scope
        errors.add(:scope, :invalid) unless feature.scopes.where(id: scope.id).exists?
      end

      def category_belongs_to_organization
        return unless feature
        return unless category
        errors.add(:category, :invalid) unless feature.categories.where(id: category.id).exists?
      end
    end
  end
end
