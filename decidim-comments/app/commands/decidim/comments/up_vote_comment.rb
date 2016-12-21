# frozen_string_literal: true
module Decidim
  module Comments
    # A command with all the business logic to upvote a comment
    class UpVoteComment < Rectify::Command
      # Public: Initializes the command.
      #
      # comment - A comment
      def initialize(comment, author)
        @comment = comment
        @author = author
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the vote wasn't create
      #
      # Returns nothing.
      def call
        @vote = @comment.up_votes.create!(author: @author)
        broadcast(:ok, @comment)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end
    end
  end
end
