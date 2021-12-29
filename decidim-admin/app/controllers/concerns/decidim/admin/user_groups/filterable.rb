# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module UserGroups
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def search_field_predicate
            :name_or_nickname_or_email_cont
          end

          def filters
            [
              :state_eq
            ]
          end

          def filters_with_values
            {
              state_eq: user_groups_states
            }
          end

          protected

          def user_groups_states
            %w(all pending rejected verified)
          end
        end
      end
    end
  end
end
