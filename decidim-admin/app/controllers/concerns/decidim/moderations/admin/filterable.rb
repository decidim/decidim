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

          def search_field_predicate
            :reportable_id_string_cont
          end

          def reportable_types
            collection.pluck(:decidim_reportable_type).uniq.sort
          end
        end
      end
    end
  end
end
