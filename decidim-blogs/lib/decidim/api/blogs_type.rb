# frozen_string_literal: true

module Decidim
  module Blogs
    class BlogsType < Decidim::Core::ComponentType
      graphql_name "Blogs"
      description "A blogs component of a participatory space."

      field :posts, type: Decidim::Blogs::PostType.connection_type, description: "List all posts", connection: true, null: false do
        argument :filter, Decidim::Blogs::PostInputFilter, "Provides several methods to filter the results", required: false
        argument :order, Decidim::Blogs::PostInputSort, "Provides several methods to order the results", required: false
      end

      field :post, type: Decidim::Blogs::PostType, description: "Finds one post", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the post", required: true
      end

      def posts(filter: {}, order: {})
        base_query = Decidim::Core::ComponentListBase.new(model_class: Post).call(object, { filter:, order: }, context)
        if context[:current_user]&.admin?
          base_query
        else
          base_query.published
        end
      end

      def post(id:)
        scope =
          if context[:current_user]&.admin?
            Post
          else
            Post.published
          end

        Decidim::Core::ComponentFinderBase.new(model_class: scope).call(object, { id: }, context)
      end
    end
  end
end
