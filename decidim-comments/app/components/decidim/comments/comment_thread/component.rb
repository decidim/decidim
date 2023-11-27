# frozen_string_literal: true

module Decidim
  module Comments
    module CommentThread
      class Component < Decidim::BaseComponent
        with_collection_parameter :commentable
        def initialize(commentable:, **options)
          @commentable = commentable
          @options = options.with_defaults(order: "older")
        end

        private

        attr_reader :commentable, :options

        def order
          options[:order]
        end
      end
    end
  end
end
