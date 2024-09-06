# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Common logic to sorting resources within the comments section
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        def available_orders
          @available_orders ||= %w(best_rated recent older most_discussed)
        end

        def default_order
          "updated"
        end

        def reorder(comments)
          case order
          when "older"
            comments.order(created_at: :desc)
          when "most_discussed"
            comments.order(comments_count: :desc)
          when "recent"
            comments.order(updated_at: :desc)
          when "best_rated"
            comments.order(most_endorsed: :desc)
          else
            comments
          end
        end
      end
    end
  end
end
