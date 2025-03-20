# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Assemblies
    module Admin
      module AssemblyMembers
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def filters
              [:ceased_date_not_null]
            end

            def filters_with_values
              {
                ceased_date_not_null: %w(true false)
              }
            end

            def base_query
              collection
            end

            def search_field_predicate
              :full_name_or_user_name_or_user_nickname_cont
            end
          end
        end
      end
    end
  end
end
