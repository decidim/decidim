# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Budgets
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          helper Decidim::Budgets::Admin::FilterableHelper

          private

          def base_query
            return collection unless taxonomy_order_or_search?

            # this is a trick to avoid duplicates when using search in associations as suggested in:
            # https://activerecord-hackery.github.io/ransack/going-further/other-notes/#problem-with-distinct-selects
            collection.includes(:taxonomies).joins(:taxonomies)
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def filters
            [
              :taxonomies_part_of_contains,
              :selected_at_null
            ]
          end

          def filters_with_values
            {
              taxonomies_part_of_contains: taxonomy_ids_hash(available_root_taxonomies),
              selected_at_null: [true, false]
            }
          end
        end
      end
    end
  end
end
