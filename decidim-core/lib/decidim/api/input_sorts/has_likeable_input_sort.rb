# frozen_string_literal: true

module Decidim
  module Core
    module HasLikeableInputSort
      def self.included(child_class)
        child_class.argument :like_count,
                             type: GraphQL::Types::String,
                             description: "Sort by number of likes, valid values are ASC or DESC",
                             required: false,
                             as: :likes_count
      end
    end
  end
end
