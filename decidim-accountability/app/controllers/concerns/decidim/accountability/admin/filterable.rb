# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Accountability
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          helper Decidim::Accountability::Admin::FilterableHelper

          private

          def base_query
            collection
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def filters
            [
                :category_id_eq,
            ]
          end

          def filters_with_values
            {
                category_id_eq: category_ids_hash(categories.first_class),
            }
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:category_id_eq]
          end
        end
      end
    end
  end
end
