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
            collection.joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          end

          def search_field_predicate
            :title_or_description_or_id_string_or_author_name_or_author_nickname_cont
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
