# frozen_string_literal: true

module Decidim
  module Comments
    class CommentableMutationType < GraphQL::Schema::Object
      graphql_name "CommentableMutation"
      description "A commentable which includes its available mutations"

      field :id, !ID, "The Commentable's unique ID"

      field :addComment, Decidim::Comments::CommentType do
        description "Add a new comment to a commentable"

        argument :body, !String, "The comments's body"
        argument :alignment, Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", default_value: 0
        argument :userGroupId, ID, "The comment's user group id. Replaces the author."

        resolve lambda { |obj, args, ctx|
          params = { "comment" => { "body" => args[:body], "alignment" => args[:alignment], "user_group_id" => args[:userGroupId], "commentable" => obj } }
          form = Decidim::Comments::CommentForm.from_params(params).with_context(
            current_organization: ctx[:current_organization],
            current_component: obj.component
          )
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
