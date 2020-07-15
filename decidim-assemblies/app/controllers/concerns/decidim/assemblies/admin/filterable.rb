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
        end
      end
    end
  end
end
