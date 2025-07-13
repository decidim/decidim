# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    # Common logic to filter admin resources.
    module Filterable
      extend ActiveSupport::Concern

      included do
        include Decidim::Paginable
        include Decidim::TranslatableAttributes

        helper Decidim::Admin::FilterableHelper

        helper_method :collection_name,
                      :extra_allowed_params,
                      :extra_filters,
                      :filters,
                      :filters_with_values,
                      :find_dynamic_translation,
                      :filter_prefix_key,
                      :query,
                      :query_params,
                      :query_params_with,
                      :query_params_without,
                      :blank_query_params,
                      :ransack_params,
                      :search_field_predicate,
                      :adjacent_items

        delegate :taxonomies, to: :current_organization
        delegate :available_root_taxonomies, to: :current_component
        delegate :available_taxonomy_ids, to: :current_component

        def query
          @query ||= base_query.ransack(ransack_params, search_context: :admin, auth_object: current_user)
        end

        private

        def check_admin_session_filters
          if (current_filters = ransack_params).present?
            admin_session_filters = session["admin_filters"] || {}
            return if admin_session_filters[filter_prefix_key] == current_filters

            current_filters = {} if current_filters[:reset_filters] == "true"

            admin_session_filters[filter_prefix_key] = current_filters
            session["admin_filters"] = admin_session_filters

            redirect_to url_for(query_params.merge(q: {})) if current_filters.blank?
          else
            @session_filter_params = {} unless session_filter_params.is_a?(Hash)
            redirect_to url_for(query_params_with(session_filter_params)) if session_filter_params.present?
          end
        end

        def filtered_collection
          paginate(query.result)
        end

        def session_filtered_collection
          @session_filtered_collection ||= begin
            query = base_query.ransack(session_filter_params, search_context: :admin, auth_object: current_user).result
            # The limit reorders as pagination does
            query.limit(query.count)
          end
        end

        # This method takes the query used by filter and selects the id of
        # each item of the filtered collection (this extra select id avoids
        # some errors where the SQL of the filtered collection query uses
        # aliases and the id is not available in the result) and uses the lag
        # and lead window functions which returns the previous and next ids in
        # the query
        def adjacent_items(item)
          query =
            <<-SQL.squish
              WITH
                collection AS (#{session_filtered_collection.select(:id).to_sql}),
                successors AS (
                  SELECT
                    id,
                    Lag(id, 1) OVER () prev_item,
                    Lead(id, 1) OVER () next_item
                  FROM
                    collection
                )
              SELECT
                prev_item,
                next_item
              FROM
                successors
              WHERE
                successors.id = #{item.id}
            SQL

          (ActiveRecord::Base.connection.exec_query(query).first || {}).compact_blank.transform_values { |id| collection.find_by(id:) }
        end

        def filter_prefix_key
          @filter_prefix_key ||= controller_name.to_sym
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

        def session_filter_params
          @session_filter_params ||= (session["admin_filters"] || {}).with_indifferent_access.fetch(filter_prefix_key, {})
        end

        # For injecting ransack params while keeping query params in links.
        def query_params_with(hash)
          query_params.merge(q: ransack_params.merge(hash))
        end

        # For rejecting ransack params while keeping query params in links.
        def query_params_without(*)
          q = ransack_params.except(*)

          return blank_query_params if q.blank?

          query_params.merge(q:)
        end

        def blank_query_params
          query_params.merge(q: { reset_filters: true })
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
        # you will not have to declare a `filters_with_values` method in your concern.
        def filters_with_values
          filters.index_with { [true, false] }
        end

        # Plural model name. Used in search_field placeholder.
        def collection_name
          query.klass.model_name.human(count: 2).downcase
        end

        def taxonomy_order_or_search?
          ransack_params[:taxonomies_part_of_contains].present? || ransack_params[:s]&.include?("taxonomies_name")
        end

        # A tree of Taxonomy IDs. Leaves are `nil`.
        def taxonomy_ids_hash(taxonomies)
          filtered_taxonomies = taxonomies.roots.or(taxonomies.where(id: available_taxonomy_ids))
          return nil if filtered_taxonomies.blank?

          filtered_taxonomies.each_with_object({}) do |taxonomy, hash|
            hash[taxonomy.id] = taxonomy_ids_hash(taxonomy.children)
          end
        end

        # Array<Symbol> of filters that implement a method to find translations.
        # Useful when translations cannot be found in i18n or come from a Model.
        def dynamically_translated_filters
          [:taxonomies_part_of_contains]
        end

        def find_dynamic_translation(filter, value)
          send("translated_#{filter}", value) if filter.in?(dynamically_translated_filters)
        end

        def translated_taxonomies_part_of_contains(id)
          translated_attribute(taxonomies.find_by(id:).name)
        end
      end
    end
  end
end
