# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Blogs
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        def available_orders
          %w(recent most_commented)
        end

        def default_order
          "recent"
        end
      end
    end
  end
end
