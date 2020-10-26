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
          vote = @comment.up_votes.find_by(author: @author)
          if vote
            vote.destroy!
          else
            @comment.up_votes.create!(author: @author)
          end
        when -1
          vote = @comment.down_votes.find_by(author: @author)
          if vote
            vote.destroy!
          else
            @comment.down_votes.create!(author: @author)
          end
        else
          return broadcast(:invalid)
        end
        broadcast(:ok, @comment)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end
    end
  end
end
