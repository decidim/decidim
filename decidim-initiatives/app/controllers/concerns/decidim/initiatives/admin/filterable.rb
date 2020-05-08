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

          def filtered_collection
            paginate(result)
          end

          def base_query
            return collection if ransack_params[search_field_predicate].blank?

            collection.joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          end

          def search_field_predicate
            :title_or_description_or_id_string_cont
          end

          def filters
            [:state_eq]
          end

          def filters_with_values
            {
              state_eq: Initiative.states.keys
            }
          end

          def result
            return query.result if ransack_params[search_field_predicate].blank?

            query.result.or(base_query.merge(author_query))
          end

          def author_query
            Initiative.by_author_name_or_nickname(ransack_params[search_field_predicate])
          end
        end
      end
    end
  end
end
