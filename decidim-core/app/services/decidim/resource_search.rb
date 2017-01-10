# frozen_string_literal: true
module Decidim
  class ResourceSearch < Searchlight::Search
    def initialize(resource, options = {})
      super(options)
      @resource = resource
    end

    def base_query
      raise "Missing feature" unless current_feature

      @resource
        .page(options[:page] || 1)
        .per(options[:per_page] || 12)
        .where(feature: current_feature)
    end

    def search_category_id
      query.where(decidim_category_id: category_ids)
    end

    private

    def category_ids
      current_feature
        .categories
        .where(id: category_id)
        .or(current_feature.categories.where(parent_id: category_id))
        .pluck(:id)
    end

    def current_feature
      options[:feature]
    end
  end
end
