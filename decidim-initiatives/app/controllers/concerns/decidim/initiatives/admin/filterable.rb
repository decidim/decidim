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
            collection.joins(:scoped_type)
          end

          def search_field_predicate
            :title_or_description_cont
          end

          def filters
            [:state_eq, :type_id_eq]
          end

          def filters_with_values
            {
              state_eq: Initiative.states.keys,
              type_id_eq: InitiativesType.where(organization: current_organization).pluck(:id)
            }
          end

          def dynamically_translated_filters
            [:type_id_eq]
          end

          def translated_type_id_eq(id)
            translated_attribute(Decidim::InitiativesType.find_by(id: id).title[I18n.locale.to_s])
          end
        end
      end
    end
  end
end
