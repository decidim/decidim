# frozen_string_literal: true

module Decidim
  module Blogs
    class BlogsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Blogs"
      description "A blogs component of a participatory space."

      field :posts, type: Decidim::Blogs::PostType.connection_type, description: "List all posts", connection: true, null: false do
        argument :order, Decidim::Blogs::PostInputSort, "Provides several methods to order the results", required: false
        argument :filter, Decidim::Blogs::PostInputFilter, "Provides several methods to filter the results", required: false
      end

      field :post, type: Decidim::Blogs::PostType, description: "Finds one post", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the post", required: true
      end

      def posts(filter: {}, order: {})
        Decidim::Core::ComponentListBase.new(model_class: Post).call(object, { filter:, order: }, context)
      end

      def post(id:)
        Decidim::Core::ComponentFinderBase.new(model_class: Post).call(object, { id: }, context)
      end
    end
  end
end
