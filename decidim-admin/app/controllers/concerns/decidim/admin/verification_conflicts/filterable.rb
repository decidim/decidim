# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module VerificationConflicts
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def search_field_predicate
            :current_user_name_or_current_user_nickname_or_current_user_email_cont
          end

          def filters
            []
          end
        end
      end
    end
  end
end
