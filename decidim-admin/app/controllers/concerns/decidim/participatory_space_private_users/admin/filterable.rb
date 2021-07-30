# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatorySpacePrivateUsers
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
              :user_invitation_sent_at_not_null,
              :user_invitation_accepted_at_not_null
            ]
          end

          def search_field_predicate
            :user_name_or_user_email_cont
          end
        end
      end
    end
  end
end
