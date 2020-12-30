# frozen_string_literal: true

module Decidim
  module Comments
    class CommentableMutationType < Decidim::Api::Types::BaseObject
      description "A commentable which includes its available mutations"

      field :id, ID, "The Commentable's unique ID", null: false

      field :add_comment, Decidim::Comments::CommentType, description: "Add a new comment to a commentable", null: true do
        argument :body, String, "The comments's body", required: true
        argument :alignment, Integer, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", default_value: 0, required: false
        argument :user_group_id, ID, "The comment's user group id. Replaces the author.", required: false
      end

      def add_comment(args: {})
        params = { "comment" => { "body" => args[:body], "alignment" => args[:alignment], "user_group_id" => args[:userGroupId], "commentable" => object } }
        form = Decidim::Comments::CommentForm.from_params(params).with_context(
          current_organization: context[:current_organization],
          current_component: object.component
        )
        Decidim::Comments::CreateComment.call(form, context[:current_user]) do
          on(:ok) do |comment|
            return comment
          end
        end
      end
    end
  end
end
