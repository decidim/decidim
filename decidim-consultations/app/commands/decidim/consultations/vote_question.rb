# frozen_string_literal: true

module Decidim
  module Consultations
    # A command with all the business logic when a user votes a question.
    class VoteQuestion < Rectify::Command
      # Public: Initializes the command.
      #
      # form   - A Decidim::Consultations::VoteForm object.
      # current_user - The current user.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        vote = build_vote
        if vote.save
          broadcast(:ok, vote)
        else
          broadcast(:invalid, vote)
        end
      end

      private

      attr_reader :form

      def build_vote
        form.context.current_question.votes.build(
          author: form.context.current_user,
          response: form.response
        )
      end
    end
  end
end
