# frozen_string_literal: true

module Decidim
  module Blogs
    class PostInputSort < Decidim::Core::BaseInputSort
      include Decidim::Core::HasTimestampInputSort
      include Decidim::Core::HasLikeableInputSort

      graphql_name "PostSort"
      description "A type used for sorting blog posts"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
    end
  end
end
