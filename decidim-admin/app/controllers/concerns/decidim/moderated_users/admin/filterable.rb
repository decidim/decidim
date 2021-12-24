# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ModeratedUsers
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def filters
            [
            ]
          end

          def filters_with_values
            {

            }
          end

          def dynamically_translated_filters
            [

            ]
          end

          def search_field_predicate
            :user_name_or_user_nickname_or_user_email_cont
          end

          def report_count

          end

          def report_reasons

          end
        end
      end
    end
  end
end
