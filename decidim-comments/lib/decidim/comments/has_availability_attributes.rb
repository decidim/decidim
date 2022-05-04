# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Shared behaviour for commentable models with enabled, start_time and
    # end_time attributes for comments.
    module HasAvailabilityAttributes
      extend ActiveSupport::Concern

      included do
        # Public: Whether the object has comments allowed based on availability
        # attributes
        def comments_allowed?
          (!comments_enabled.nil? && comments_enabled) &&
            (comments_start_time.blank? || comments_start_time <= Time.current) &&
            (comments_end_time.blank? || comments_end_time > Time.current)
        end
      end
    end
  end
end
