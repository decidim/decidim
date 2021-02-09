# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to upvote a comment
    class VoteComment < Rectify::Command
      # Public: Initializes the command.
      #
      # comment - A comment
      # author - A user
      # options - An optional hash of options (default: { weight: 1 })
      #         * weight: The vote's weight. Valid values 1 and -1.
      def initialize(comment, author, options = { weight: 1 })
        @comment = comment
        @author = author
        @weight = options[:weight]
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the vote wasn't create
      #
      # Returns nothing.
      def call
        case @weight
        when 1
          previous_vote = @comment.up_votes.find_by(author: @author)
          if previous_vote
            previous_vote.destroy!
          else
            @vote = @comment.up_votes.create!(author: @author)
          end
        when -1
          previous_vote = @comment.down_votes.find_by(author: @author)
          if previous_vote
            previous_vote.destroy!
          else
            @vote = @comment.down_votes.create!(author: @author)
          end
        else
          return broadcast(:invalid)
        end

        notify_comment_author if @vote
        broadcast(:ok, @comment)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      def notify_comment_author
        Decidim::EventsManager.publish(
          event: "decidim.events.comments.comment_#{upvote? ? "upvoted" : "downvoted"}",
          event_class: upvote? ? Decidim::Comments::CommentUpvotedEvent : Decidim::Comments::CommentDownvotedEvent,
          resource: @comment.commentable,
          affected_users: [@comment.author],
          extra: {
            comment_id: @comment.id,
            weight: @weight,
            downvotes: @comment.down_votes.count,
            upvotes: @comment.up_votes.count
          }
        )
      end

      private

      def upvote?
        @weight.positive?
      end
    end
  end
end
