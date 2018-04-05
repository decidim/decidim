# frozen_string_literal: true

module Decidim
  module Consultations
    # A command with all the business logic when a user unvotes a question.
    class UnvoteQuestion < Rectify::Command
      # Public: Initializes the command.
      #
      # question   - A Decidim::Consultations::Question object.
      # current_user - The current user.
      def initialize(question, current_user)
        @question = question
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the question.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_vote
        broadcast(:ok, @question)
      end

      private

      def destroy_vote
        @question
          .votes
          .where(author: @current_user)
          .destroy_all
      end
    end
  end
end
