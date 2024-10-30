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
              :status_id_eq
            ]
          end

          def filters_with_values
            {
              taxonomies_part_of_contains: taxonomy_ids_hash(available_root_taxonomies),
              status_id_eq: status_ids_hash(statuses)
            }
          end

          # Cannot user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:taxonomies_part_of_contains, :status_id_eq]
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
