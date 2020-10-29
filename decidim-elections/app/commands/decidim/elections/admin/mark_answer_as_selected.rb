# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when an admin marks an answer
      # as selected.
      class MarkAnswerAsSelected < Rectify::Command
        def initialize(answer, current_user)
          @answer = answer
          @current_user = current_user
        end

        # Selects the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          select_answer!

          broadcast(:ok, answer)
        end

        private

        attr_reader :answer

        def invalid?
          !answer.question.total_votes.positive?
        end

        def select_answer!
          answer.update!(
            selected: !answer.selected
          )
        end
      end
    end
  end
end
