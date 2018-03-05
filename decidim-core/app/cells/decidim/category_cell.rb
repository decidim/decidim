# frozen_string_literal: true

module Decidim
  class CategoryCell < Decidim::ViewModel
    include LayoutHelper

    def show
      render if category?
    end

    private

    def link_to_category
      link_to name, category_path
    end

    def name
      model.translated_name
    end

    def resource
      context[:resource]
    end

    def category?
      resource.category.present?
    end

    def category_path
      resource_locator(resource).index(filter: { category_id: model.id })
    end
  end
end
