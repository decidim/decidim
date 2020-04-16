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
    # Check if the option component was provided.
    def base_query
      raise "Missing component" unless component

      @scope.where(component: component)
    end

    # Handle the category_id filter
    def search_category_id
      return query if category_ids.include?("all")

      query
        .includes(:categorization)
        .where(decidim_categorizations: { decidim_category_id: all_category_ids })
    end

    # Handles the scope_ids filter. When we want to show only those that do not
    # have a scope_ids set, we cannot pass an empty String or nil because Searchlight
    # will automatically filter out these params, so the method will not be used.
    # Instead, we need to pass a fake ID and then convert it inside. In this case,
    # in order to select those elements that do not have a scope_ids set we use
    # `"global"` as parameter, and in the method we do the needed changes to search
    # properly.
    def search_scope_id
      return query if scope_ids.include?("all")

      clean_scope_ids = scope_ids

      conditions = []
      conditions << "#{query.model_name.plural}.decidim_scope_id IS NULL" if clean_scope_ids.delete("global")
      conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

      query.includes(:scope).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
    end

    private

    # Private: Creates an array of category ids.
    # It contains categories' subcategories ids as well.
    def all_category_ids
      cat_ids = category_ids.without("without")

      component
        .categories
        .where(id: cat_ids)
        .or(component.categories.where(parent_id: cat_ids))
        .pluck(:id).tap { |ids| ids.prepend(nil) if category_ids.include?("without") }
    end

    # Private: Returns an array with checked category ids.
    def category_ids
      [category_id].flatten
    end

    # Private: Returns an array with checked scope ids.
    def scope_ids
      if scope_id.is_a?(Hash)
        scope_id.values
      else
        [scope_id].flatten
      end
    end

    # Private: Since component is not used by a search method we need
    # to define the method manually.
    def component
      options[:component]
    end
  end
end
