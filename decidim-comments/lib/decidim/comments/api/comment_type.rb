# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    class CommentType < GraphQL::Schema::Object
      graphql_name "Comment"
      description "A comment"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::TimestampsInterface

      field :author, Decidim::Core::AuthorInterface, null: true, description: "The resource author" do
        def resolve(obj:, _args:, _ctx:)
          obj.user_group || obj.author
        end
      end

      field :id, ID, null: false, description: "The Comment's unique ID"

      field :sgid, String, null: false, description: "The Comment's signed global id" do
        def resolve(obj:, _args:, _ctx:)
          obj.to_sgid.to_s
        end
      end

      field :body, String, null: false, description: "The comment message" do
        def resolve(obj:, _args:, _ctx:)
          obj.translated_body
        end
      end

      field :formattedBody, String, null: false, description: "The comment message ready to display (it is expected to include HTML)" do
        def resolve(obj:, _args:, _ctx:)
          obj.formatted_body
        end
      end

      field :formattedCreatedAt, String, null: false, description: "The creation date of the comment in relative format" do
        def resolve(obj:, _args:, _ctx:)
          obj.friendly_created_at
        end
      end

      field :alignment, Int, null: true, description: "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'"

      field :upVotes, Int, null: false, description: "The number of comment's upVotes" do
        def resolve(obj:, _args:, _ctx:)
          obj.up_votes.size
        end
      end

      field :upVoted, Boolean, null: false, description: "Check if the current user has upvoted the comment" do
        def resolve(obj:, _args:, _ctx:)
          obj.up_voted_by?(ctx[:current_user])
        end
      end

      field :downVotes, Int, null: false, description: "The number of comment's downVotes" do
        def resolve(obj:, _args:, _ctx:)
          obj.down_votes.size
        end
      end

      field :downVoted, Boolean, null: false, description: "Check if the current user has downvoted the comment" do
        def resolve(obj:, _args:, _ctx:)
          obj.down_voted_by?(ctx[:current_user])
        end
      end

      field :hasComments, Boolean, null: false, description: "Check if the commentable has comments" do
        def resolve(obj:, _args:, _ctx:)
          obj.comment_threads.size.positive?
        end
      end

      field :alreadyReported, Boolean, null: false, description: "Check if the current user has reported the comment" do
        def resolve(obj:, _args:, _ctx:)
          obj.reported_by?(ctx[:current_user])
        end
      end

      field :userAllowedToComment, Boolean, null: false, description: "Check if the current user can comment" do
        def resolve(obj:, _args:, _ctx:)
          obj.root_commentable.commentable? && obj.root_commentable.user_allowed_to_comment?(ctx[:current_user])
        end
      end
    end
  end
end
