# frozen_string_literal: true

module Decidim
  module Comments
    class CommentableMutationType < Decidim::Api::Types::BaseObject
      description "A commentable which includes its available mutations"

      field :add_comment, Decidim::Comments::CommentType, description: "Add a new comment to a commentable", null: true do
        argument :alignment, GraphQL::Types::Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", default_value: 0, required: false
        argument :body, GraphQL::Types::String, "The comments's body", required: true
      end
      field :id, GraphQL::Types::ID, "The Commentable's unique ID", null: false

      def add_comment(body:, alignment: nil)
        params = { "comment" => { "body" => body, "alignment" => alignment, "commentable" => object } }
        form = Decidim::Comments::CommentForm.from_params(params).with_context(
          current_organization: context[:current_organization],
          current_user: context[:current_user],
          current_component: object.component
        )
        Decidim::Comments::CreateComment.call(form) do
          on(:ok) do |comment|
            return comment
          end
        end
      end
    end
  end
end
