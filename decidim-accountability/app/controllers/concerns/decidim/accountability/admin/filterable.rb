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
              :scope_id_eq,
              :category_id_eq,
              :status_id_eq
            ]
          end

          def filters_with_values
            {
              scope_id_eq: scope_ids_hash(scopes.top_level),
              category_id_eq: category_ids_hash(categories.first_class),
              status_id_eq: status_ids_hash(statuses)
            }
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:scope_id_eq, :category_id_eq, :status_id_eq]
          end

          def status_ids_hash(statuses)
            statuses.each_with_object({}) { |status, hash| hash[status.id] = status.id }
          end

          def translated_status_id_eq(id)
            translated_attribute(statuses.find_by(id:).name)
          end
        end
      end
    end
  end
end
