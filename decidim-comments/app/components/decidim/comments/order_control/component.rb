# frozen_string_literal: true

module Decidim
  module Comments
    module OrderControl
      class Component < Decidim::BaseComponent
        delegate :decidim_comments, to: :helpers

        def initialize(commentable, options = {})
          @commentable = commentable
          @options = options.with_defaults(order: "older")
        end

        private
        attr_reader :commentable, :options

        def order
          options[:order]
        end

        def available_orders
          %w(best_rated recent older most_discussed)
        end
      end
    end
  end
end
