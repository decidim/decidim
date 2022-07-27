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
            collection.joins(:scoped_type).left_joins(:area).joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          end

          def search_field_predicate
            :title_or_description_or_id_string_or_author_name_or_author_nickname_cont
          end

          def filters
            [:state_eq, :type_id_eq, :decidim_area_id_eq]
          end

          def filters_with_values
            {
              state_eq: Initiative.states.keys,
              type_id_eq: InitiativesType.where(organization: current_organization).pluck(:id),
              decidim_area_id_eq: current_organization.areas.pluck(:id)
            }
          end

          def dynamically_translated_filters
            [:type_id_eq, :decidim_area_id_eq]
          end

          def translated_type_id_eq(id)
            translated_attribute(Decidim::InitiativesType.find_by(id:).title[I18n.locale.to_s])
          end

          def translated_decidim_area_id_eq(id)
            translated_attribute(Decidim::Area.find_by(id:).name[I18n.locale.to_s])
          end
        end
      end
    end
  end
end
