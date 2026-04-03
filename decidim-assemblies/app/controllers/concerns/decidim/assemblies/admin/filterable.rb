# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Assemblies
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          # Unless we are explicitly looking for child assemblies, we filter them out.
          def base_query
            return collection if ransack_params[:parent_id_eq]

            collection.parent_assemblies
          end

          def extra_filters
            [:parent_id_eq]
          end

          def filters
            [:with_any_access_mode, :published_at_null]
          end

          def filters_with_values
            {
              with_any_access_mode: access_modes,
              published_at_null: [true, false]
            }
          end

          def access_modes
            Assembly::ACCESS_MODES.keys
          end
        end
      end
    end
  end
end
