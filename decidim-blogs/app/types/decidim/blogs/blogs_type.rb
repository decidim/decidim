# frozen_string_literal: true

module Decidim
  module Blogs
    BlogsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Blogs"
      description "A blogs component of a participatory space."

      connection :posts, PostType.connection_type do
        resolve ->(component, _args, _ctx) {
                  PostsTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:post, PostType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          PostsTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module PostsTypeHelper
      def self.base_scope(component)
        Post.where(component: component)
      end
    end
  end
end
