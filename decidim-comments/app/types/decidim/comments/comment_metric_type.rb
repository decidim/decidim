# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Comments::CommentMetricInterface }]

      name "CommentMetricType"
      description "A Comment component of a participatory space."
    end

    module CommentMetricTypeHelper
      def self.base_scope(_organization)
        Comment.all
      end
    end
  end
end
