# frozen_string_literal: true
module Decidim
  # This is the base class to be used by other search services.
  # Searchlight documentation: https://github.com/nathanl/searchlight
  class ResourceSearch < Searchlight::Search
    # Initialize the Searchlight::Search base class with the options provided.
    #
    # scope - The scope used to create the base query
    # options - A hash of options to modify the search. These options will be
    #          converted to methods by SearchLight so they can be used on filter #
    #          methods. (Default {})
    def initialize(scope, options = {})
      super(options)
      @scope = scope
    end

    # Creates the SearchLight base query.
    # Check if the option feature was provided.
    def base_query
      # raise order_start_time.inspect
      raise "Missing feature" unless feature

      @scope
        .page(options[:page] || 1)
        .per(options[:per_page] || 12)
        .where(feature: feature)
    end

    # Handle the category_id filter
    def search_category_id
      query.where(decidim_category_id: category_ids)
    end

    private

    # Private: Creates an array of category ids.
    # It contains categories' subcategories ids as well.
    def category_ids
      feature
        .categories
        .where(id: category_id)
        .or(feature.categories.where(parent_id: category_id))
        .pluck(:id)
    end

    # Private: Since feature is not used by a search method we need
    # to define the method manually.
    def feature
      options[:feature]
    end
  end
end
