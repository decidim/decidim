# frozen_string_literal: true

module Decidim
  module Comments
    CommentableMutationType = GraphQL::ObjectType.define do
      name "CommentableMutation"
      description "A commentable which includes its available mutations"

      field :id, !types.ID, "The Commentable's unique ID"

      field :addComment, Decidim::Comments::CommentType do
        description "Add a new comment to a commentable"

        argument :body, !types.String, "The comments's body"
        argument :alignment, types.Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", default_value: 0
        argument :userGroupId, types.ID, "The comment's user group id. Replaces the author."

        resolve lambda { |obj, args, ctx|
          params = { "comment" => { "body" => args[:body], "alignment" => args[:alignment], "user_group_id" => args[:userGroupId], "commentable" => obj } }
          form = Decidim::Comments::CommentForm.from_params(params).with_context(
            current_organization: ctx[:current_organization],
            current_component: obj.component
          )
          raise GraphQL::ExecutionError, "not allowed" unless form.commentable.user_allowed_to_comment?(ctx[:current_user])

          Decidim::Comments::CreateComment.call(form, ctx[:current_user]) do
            on(:ok) do |comment|
              return comment
            end
          end
        }
      end
    end
  end
end
