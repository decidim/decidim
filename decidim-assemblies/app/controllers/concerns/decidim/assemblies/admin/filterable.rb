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
            [:private_space_eq, :published_at_null]
          end

          def filters_with_values
            {
              private_space_eq: [true, false],
              published_at_null: [true, false]
            }
          end
        end
      end
    end
  end
end
