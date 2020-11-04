# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Moderations
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def filters
            [
              :reportable_type_string_eq
            ]
          end

          def filters_with_values
            {
              reportable_type_string_eq: reportable_types
            }
          end

          def dynamically_translated_filters
            [:reportable_type_string_eq]
          end

          def translated_reportable_type_string_eq(value)
            value.constantize.name.demodulize
          end

          # Private: the predicate used by `Ransack` to perform a search. We used `reported` instead
          #          of `reportable` because otherwise `Ransack` try to traverse the polymorphic
          #          association automatically and it fails.
          def search_field_predicate
            :reported_id_string_or_reported_content_cont
          end

          def reportable_types
            collection.pluck(:decidim_reportable_type).uniq.sort
          end
        end
      end
    end
  end
end
