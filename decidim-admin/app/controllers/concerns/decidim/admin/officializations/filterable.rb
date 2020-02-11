# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module Officializations
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
            [:officialized_at_null]
          end
        end
      end
    end
  end
end
