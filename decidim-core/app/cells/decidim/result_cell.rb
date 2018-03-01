# frozen_string_literal: true

module Decidim
  class ResultCell < Decidim::ViewModel
    #include LayoutHelper

    def show
      cell(resource_cell, model.resource) if category?
    end

    private

    def resource_type
      model.class.model_name.human
    end

    def resource_path
      resource_locator(model).path
    end

    def resource_cell
      model.resource.class.resource_manifest.cell
    end

    def feature
      model
    end

    def category?
      model.resource.category.present?
    end

  end
end
