# frozen_string_literal: true

module Decidim
  # This is the base class to be used by other ParticipatorySpace search services
  # Searchlight documentation: https://github.com/nathanl/searchlight
  class ParticipatorySpaceSearch < Searchlight::Search
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
    def base_query
      @scope = @scope.where(organization: organization)
      @scope = @scope.published if @scope.respond_to?(:published)
      @scope = @scope.visible_for(current_user) if @scope.respond_to?(:visible_for)
    end

    # Handles the scope_id filter.
    def search_scope_id
      clean_scope_ids = if scope_id.is_a?(Hash)
                          scope_id.values
                        else
                          [scope_id].flatten
                        end
      conditions = []
      conditions << "decidim_scope_id IS NULL" if clean_scope_ids.delete("global")
      conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

      query.includes(:scope).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
    end

    # Handle the area_id filter
    def search_area_id
      query.includes(:area).where(decidim_area_id: area_id)
    end

    private

    def organization
      options[:organization]
    end

    def current_user
      options[:current_user]
    end
  end
end
