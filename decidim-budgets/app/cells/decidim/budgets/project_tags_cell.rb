# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell overrides *_path methods from Decidim::TagsCell for project tags
    class ProjectTagsCell < Decidim::TagsCell
      private

      def category_path
        resource_locator([model.budget, model]).index(filter: { category_id: [model.category.id.to_s] })
      end

      def scope_path
        resource_locator([model.budget, model]).index(filter: { scope_id: [model.scope.id] })
      end
    end
  end
end
