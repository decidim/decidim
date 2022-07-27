# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    # Common logic to filter admin resources.
    module Filterable
      extend ActiveSupport::Concern

      included do
        include Decidim::Admin::Paginable
        include Decidim::TranslatableAttributes

        helper Decidim::Admin::FilterableHelper

        helper_method :collection_name,
                      :extra_allowed_params,
                      :extra_filters,
                      :filters,
                      :filters_with_values,
                      :find_dynamic_translation,
                      :query,
                      :query_params,
                      :query_params_with,
                      :query_params_without,
                      :ransack_params,
                      :search_field_predicate

        delegate :categories, to: :current_component
        delegate :scopes, to: :current_organization

        def query
          @query ||= base_query.ransack(ransack_params, search_context: :admin, auth_object: current_user)
        end

        private

        def filtered_collection
          paginate(query.result)
        end

        def base_query
          raise NotImplementedError, "A base query is needed to filter admin resources"
        end

        def query_params
          params.permit(*allowed_query_params).to_h.deep_symbolize_keys
        end

        def allowed_query_params
          [*extra_allowed_params, { q: {} }]
        end

        # Non ransack params (outside :q) to be allowed in the query links.
        # Also, used in FilterableHelper#applied_filters_hidden_field_tags
        # to ensure that these params are kept in the search_form_for.
        def extra_allowed_params
          [:per_page]
        end

        def ransack_params
          query_params[:q] || {}
        end

        # For injecting ransack params while keeping query params in links.
        def query_params_with(hash)
          query_params.merge(q: ransack_params.merge(hash))
        end

        # For rejecting ransack params while keeping query params in links.
        def query_params_without(*filters)
          query_params.merge(q: ransack_params.except(*filters))
        end

        # Ransack predicate to use in the search_form_for.
        def search_field_predicate
          :title_cont
        end

        # Informs which filters are being used IN the dropdown.
        # Array<Symbol> of ransack params (inside :q) keys used in:
        # - FilterableHelper#applied_filters_tags
        # To build the tags that inform which filters are being applied and
        # that allow to discard them.
        # - FilterableHelper#applied_filters_hidden_field_tags
        # To ensure that filters are kept in the search_form_for.
        def filters
          [:private_space_eq, :published_at_null]
        end

        # Informs which filters are being used OUTSIDE the dropdown.
        # Optional Array<Symbol> of ransack params (inside :q) keys
        # used in FilterableHelper#applied_filters_hidden_field_tags
        # to ensure that these filters are kept in the search_form_for.
        def extra_filters
          []
        end

        # A Hash of filters as Symbol and its options as Array or Hash.
        # Needed to build the tree of links used to build the dropdown submenu.
        # Array values are used to build simple dropdown submenus with one level.
        # Hash values are used to build nested dropdown submenus with many levels.
        # By default, uses the Symbols in `filters` as keys and injects an Array
        # with true and false as values. If these values fit your filtering needs,
        # you won't have to declare a `filters_with_values` method in your concern.
        def filters_with_values
          filters.index_with { [true, false] }
        end

        # Plural model name. Used in search_field placeholder.
        def collection_name
          query.klass.model_name.human(count: 2)
        end

        # A tree of Category IDs. Leaves are `nil`.
        def category_ids_hash(categories)
          categories.each_with_object({}) do |category, hash|
            hash[category.id] = category.subcategories.any? ? category_ids_hash(category.subcategories) : nil
          end
        end

        # A tree of Scope IDs. Leaves are `nil`.
        def scope_ids_hash(scopes)
          scopes.each_with_object({}) do |scope, hash|
            hash[scope.id] = scope.children.any? ? scope_ids_hash(scope.children) : nil
          end
        end

        # Array<Symbol> of filters that implement a method to find translations.
        # Useful when translations cannot be found in i18n or come from a Model.
        def dynamically_translated_filters
          [:scope_id_eq, :category_id_eq]
        end

        def find_dynamic_translation(filter, value)
          send("translated_#{filter}", value) if filter.in?(dynamically_translated_filters)
        end

        def translated_scope_id_eq(id)
          translated_attribute(scopes.find_by(id:).name)
        end

        def translated_category_id_eq(id)
          translated_attribute(categories.find_by(id:).name)
        end
      end
    end
  end
end
