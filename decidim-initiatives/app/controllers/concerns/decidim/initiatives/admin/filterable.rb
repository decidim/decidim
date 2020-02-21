# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def search_field_predicate
            :title_or_description_cont
          end

          def filters
            [:state_eq]
          end

          def filters_with_values
            {
              state_eq: Initiative.states.keys
            }
          end
        end
      end
    end
  end
end
