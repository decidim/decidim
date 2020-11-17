# frozen_string_literal: true

module Decidim
  module Blogs
    class BlogsType < GraphQL::Schema::Object
      graphql_name "Blogs"
      implements Decidim::Core::ComponentInterface

      description "A blogs component of a participatory space."

      field :posts,
            type: PostType.connection_type,
            description: "List all posts",
            null: false do
        argument :order, PostInputSort, required: false, description: "Provides several methods to order the results"
        argument :filter, PostInputFilter, required: false, description: "Provides several methods to filter the results"

        def resolve(component, args, _ctx)
          Decidim::Core::ComponentListBase.new(model_class: Post).call(component, args, _ctx)
        end
      end

      field :post,
            type: PostType,
            description: "Finds one post",
            null: true do
        argument :id, ID, required: true, description: "The ID of the post"

        def resolve(component, args, _ctx)
          Decidim::Core::ComponentListBase.new(model_class: Post).call(component, args, _ctx)
        end
      end
    end
  end
end
