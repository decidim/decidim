# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Surveys
    # A controller concern to specify default filter parameters for the
    # controller resources within a surveys component.
    module ComponentFilterable
      extend ActiveSupport::Concern

      included do
        private

        def default_filter_params
          {
            activity: %w(all),
            with_any_date: "open",
            with_any_scope: nil,
            with_any_state: %w(open closed)
          }
        end
      end
    end
  end
end
