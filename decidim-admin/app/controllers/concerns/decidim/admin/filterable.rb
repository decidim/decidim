# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    # Common logic to filter admin resources.
    module Filterable
      extend ActiveSupport::Concern

      included do
        include Decidim::Admin::Paginable

        helper Decidim::Admin::FilterableHelper

        helper_method :collection_name,
                      :extra_filters,
                      :filters,
                      :filters_with_values,
                      :filters_dropdown_menu_partial,
                      :query,
                      :query_params_with,
                      :query_params_without,
                      :ransack_params,
                      :search_field_predicate

        private

        def filtered_collection
          paginate(query.result)
        end

        def base_query
          raise NotImplementedError, "A base query is needed to filter admin resources"
        end

        def query
          @query ||= base_query.ransack(ransack_params)
        end

        def query_params
          params.permit(*allowed_query_params).to_h.deep_symbolize_keys
        end

        def allowed_query_params
          [:per_page, q: {}]
        end

        def ransack_params
          query_params[:q] || {}
        end

        def query_params_with(hash)
          query_params.merge(q: ransack_params.merge(hash))
        end

        def query_params_without(*filters)
          query_params.merge(q: ransack_params.except(*filters))
        end

        def search_field_predicate
          :title_cont
        end

        def filters
          [:private_space_eq, :published_at_null]
        end

        # An optional array of symbols of extra ransack paramaters
        # to be passed as hidden_fields in the search form.
        def extra_filters
          []
        end

        # The partial path as String to render a custom view instead of the
        # default one, useful for building complex dropdown menu options.
        def filters_dropdown_menu_partial
          params["controller"] + "/filters_dropdown_menu"
        end

        # A Hash of the filters as Symbol and its values as Array.
        def filters_with_values
          filters.each_with_object({}) do |filter, hash|
            hash[filter] = [true, false]
          end
        end

        def collection_name
          query.klass.model_name.human(count: 2)
        end
      end
    end
  end
end
