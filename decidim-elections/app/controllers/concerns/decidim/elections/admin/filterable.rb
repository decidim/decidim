# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Elections
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            Election
              .not_hidden
              .where(component: current_component)
              .order(start_at: :desc)
          end
        end
      end
    end
  end
end
