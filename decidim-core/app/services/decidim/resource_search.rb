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
      query
        .includes(:categorization)
        .where(decidim_categorizations: { decidim_category_id: category_ids })
    end

    # Handles the scope_id filter. When we want to show only those that do not
    # have a scope_id set, we cannot pass an empty String or nil because Searchlight
    # will automatically filter out these params, so the method will not be used.
    # Instead, we need to pass a fake ID and then convert it inside. In this case,
    # in order to select those elements that do not have a scope_id set we use
    # `"global"` as parameter, and in the method we do the needed changes to search
    # properly.
    def search_scope_id
      clean_scope_ids = if scope_id.is_a?(Hash)
                          scope_id.values
                        else
                          [scope_id].flatten
                        end

      conditions = []
      conditions << "decidim_scope_id IS NULL" if clean_scope_ids.delete("global")

      clean_scope_ids.map!(&:to_i)

      if clean_scope_ids.any?
        conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count)
        conditions << "decidim_scopes.id IN (?)"
      end

      query.includes(:scope).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids, clean_scope_ids)
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
