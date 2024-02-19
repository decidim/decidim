# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Meetings
    module Admin
      module Invites
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def filters
              [:accepted_at_not_null, :rejected_at_not_null, :sent_at_not_null]
            end

            def base_query
              collection
            end

            def search_field_predicate
              :user_name_or_user_email_cont
            end
          end
        end
      end
    end
  end
end
