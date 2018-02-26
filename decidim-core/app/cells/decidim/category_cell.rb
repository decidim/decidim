# frozen_string_literal: true

module Decidim
  class CategoryCell < Decidim::ViewModel
    include LayoutHelper

    def show
      render
    end

    private

    def link_to_category
      link_to name, category_path
      # link_to translated_attribute(model.name), resource_locator(model).index(filter: { category_id: model.id })
    end

    def name
      model.name[I18n.locale.to_s]
    end

    def category_path
      return "#"
    end
  end
end
