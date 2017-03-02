# frozen_string_literal: true
module Decidim
  # This is the base class to be used by other search services.
  # Searchlight documentation: https://github.com/nathanl/searchlight
  class ResourceSearch < Searchlight::Search
    # Initialize the Searchlight::Search base class with the options provided.
    #
    # scope   - The scope used to create the base query
    # options - A hash of options to modify the search. These options will be
    #          converted to methods by SearchLight so they can be used on filter
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

      @scope.where(feature: feature)
    end

    # Handle the category_id filter
    def search_category_id
      query.where(decidim_category_id: category_ids)
    end

    # Handles the scope_id filter. When we want to show only those that do not
    # have a scope_id set, we cannot pass an empty String or nil because Searchlight
    # will automatically filter out these params, so the method will not be used.
    # Instead, we need to pass a fake ID and then convert it inside. In this case,
    # in order to select those elements that do not have a scope_id set we use
    # `"global"` as parameter, and in the method we do the needed changes to search
    # properly.
    #
    # You can use the `search_organization_scopes` helper method, defined in
    # `Decidim::OrganizationScopesHelper`, to render the collection needed for the
    # `collection_check_boxes` form method.
    def search_scope_id
      clean_scope_ids = [scope_id].flatten.map{ |id| id == "global" ? nil : id }
      query.where(decidim_scope_id: clean_scope_ids)
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
