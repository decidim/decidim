# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # A command with all the logic to upvote or downvote a suggestion.
    class VoteSuggestion < Decidim::Command
      WEIGHTS = [-1, 1].freeze

      # Public: Initializes the command.
      #
      # suggestion - A suggestion
      # author - A user
      # options - A hash of options
      #         * weight: The vote's weight. Valid values 1 and -1.
      def initialize(suggestion, author, options = {})
        @suggestion = suggestion
        @author = author
        @weight = options[:weight]
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the vote was not created.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless WEIGHTS.include?(@weight)

        @suggestion.with_lock do
          vote = @suggestion.votes.find_by(author: @author)

          if vote&.weight == @weight
            vote.destroy!
          elsif vote
            vote.update!(weight: @weight)
          else
            @suggestion.votes.create!(author: @author, weight: @weight)
          end
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end
    end
  end
end
