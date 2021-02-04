# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a commentable object.
    class CommentableType < Decidim::Api::Types::BaseObject
      description "A commentable object"

      implements Decidim::Comments::CommentableInterface
    end
  end
end
