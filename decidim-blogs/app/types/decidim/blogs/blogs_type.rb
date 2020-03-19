# frozen_string_literal: true

module Decidim
  module Blogs
    BlogsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Blogs"
      description "A blogs component of a participatory space."

      connection :posts,
                 type: PostType.connection_type,
                 description: "List all posts",
                 function: PostListHelper.new(model_class: Post)
      field :post,
            type: PostType,
            description: "Finds one post",
            function: PostFinderHelper.new(model_class: Post)
    end

    class PostListHelper < Decidim::Core::ComponentListBase
      argument :order, PostInputSort, "Provides several methods to order the results"
      argument :filter, PostInputFilter, "Provides several methods to filter the results"
    end

    class PostFinderHelper < Decidim::Core::ComponentFinderBase
      argument :id, !types.ID, "The ID of the post"
    end
  end
end
