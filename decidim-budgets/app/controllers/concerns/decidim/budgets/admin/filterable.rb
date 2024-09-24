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
            collection.includes(:taxonomies).joins(:taxonomies)
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def filters
            [
              :taxonomies_id_eq,
              :selected_at_null
            ]
          end

          def filters_with_values
            {
              taxonomies_id_eq: taxonomy_ids_hash(available_root_taxonomies),
              selected_at_null: [true, false]
            }
          end
        end
      end
    end
  end
end
