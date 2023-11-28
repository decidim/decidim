# frozen_string_literal: true

module Decidim
  module Comments
    module AddComment
      class Component < Decidim::BaseComponent

        attr_reader :commentable, :root_depth

        def initialize(commentable, root_depth)
          @commentable = commentable
          @root_depth = root_depth
        end
      end
    end
  end
end
