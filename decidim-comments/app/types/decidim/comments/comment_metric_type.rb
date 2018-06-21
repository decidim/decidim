# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Comments::CommentMetricInterface }]

      name "CommentMetricType"
      description "A Comment component of a participatory space."

      field :count, !types.Int, "Total comments" do
        resolve ->(organization, _args, _ctx) {
          CommentMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[CommentMetricObjectType], "Data for each comment" do
        resolve ->(organization, _args, _ctx) {
          CommentMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module CommentMetricTypeHelper
      def self.base_scope(organization)
        Comment.all
      end
    end
  end
end
