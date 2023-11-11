# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Meetings
    # A controller concern to specify default filter parameters for the
    # controller resources within a meetings component.
    module ComponentFilterable
      extend ActiveSupport::Concern

      included do
        private

        def default_filter_params
          {
            search_text_cont: "",
            with_any_date: "upcoming",
            activity: "all",
            with_availability: "",
            with_any_scope: nil,
            with_any_category: nil,
            with_any_state: nil,
            with_any_origin: nil,
            with_any_type: nil
          }
        end
      end
    end
  end
end
