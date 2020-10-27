# frozen_string_literal: true

module Decidim
  # This is the base class to be used by other search services.
  # Searchlight documentation: https://github.com/nathanl/searchlight
  class ResourceSearch < Searchlight::Search
    attr_reader :user, :organization, :component

    # Initialize the Searchlight::Search base class with the options provided.
    #
    # scope   - The scope used to create the base query
    # options - A hash of options to modify the search. These options will be
    #          converted to methods by SearchLight so they can be used on filter
    #          methods. (Default {})
    def initialize(scope, options = {})
      super(options)
      @scope = scope
      @user = options[:current_user] || options[:user]
      @component = options[:component]
      @organization = options[:organization] || component&.organization
    end

    # Public: Companion method to `search_search_text` which defines the
    # attributes where we should search for text values in a model.
    def self.text_search_fields(*fields)
      @text_search_fields = fields if fields.any?
      @text_search_fields
    end

    # Handle the search_text filter. We have to cast the JSONB columns
    # into a `text` type so that we can search.
    def search_search_text
      return query unless self.class.text_search_fields.any?

      fields = self.class.text_search_fields.dup

      text_query = query.where(localized_search_text_in("#{query.model_name.plural}.#{fields.shift}"), text: "%#{search_text}%")

      fields.each do |field|
        text_query = text_query.or(query.where(localized_search_text_in("#{query.model_name.plural}.#{field}"), text: "%#{search_text}%"))
      end
      text_query
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

    # Handle the origin filter.
    def search_origin
      renamed_origin = Array(origin).map do |search_value|
        "#{search_value}_origin"
      end
      apply_scopes(%w(official_origin citizens_origin user_group_origin meeting_origin), renamed_origin)
    end

    # We overwrite the `results` method to ensure we only return unique
    # results. We can't use `#uniq` because it returns an Array and we're
    # adding scopes in the controller, and `#distinct` doesn't work here
    # because in the later scopes we're ordering by `RANDOM()` in a DB level,
    # and `SELECT DISTINCT` doesn't work with `RANDOM()` sorting, so we need
    # to perform two queries.
    #
    # The correct behaviour is backed by tests.
    def results
      base_query.model.where(id: super.pluck(:id))
    end

    private

    # Private: To be used by classes that inherit from ResourceSearch.
    #
    # This method is useful when the values of the filters match the names of
    # defined scopes in a model, it applies those scopes that are included in
    # the search values.
    #
    # Example:
    #   Consider you want to filter by state, and your model has an `open` and
    #   a `closed` ActiveRecord scope.
    #
    #   def search_state
    #     apply_scopes(%w(open closed), state)
    #   end
    #
    #   In this scenario, the `state` variable has the input by the use, who
    #   has selected which states they want to see. `states` here is an array
    #   of strings.
    #
    # Returns an ActiveRecord::Relation.
    def apply_scopes(scopes, search_values)
      search_values = Array(search_values)

      conditions = scopes.map do |scope|
        search_values.member?(scope.to_s) ? query.try(scope) : nil
      end.compact

      return query unless conditions.any?

      scoped_query = query.where(id: conditions.shift)

      conditions.each do |condition|
        scoped_query = scoped_query.or(query.where(id: condition))
      end

      scoped_query
    end

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
      Array(category_id)
    end

    # Private: Returns an array with checked scope ids.
    def scope_ids
      if scope_id.is_a?(Hash)
        scope_id.values
      else
        Array(scope_id)
      end
    end

    # Internal: builds the needed query to search for a text in the organization's
    # available locales. Note that it is intended to be used as follows:
    #
    # Example:
    #   Resource.where(localized_search_text_for(:title, text: "my_query"))
    #
    # The Hash with the `:text` key is required or it won't work.
    def localized_search_text_in(field)
      organization.available_locales.map { |l| "#{field} ->> '#{l}' ILIKE :text" }.join(" OR ")
    end
  end
end
