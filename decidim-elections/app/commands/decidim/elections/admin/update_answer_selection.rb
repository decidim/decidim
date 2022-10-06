# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when an admin marks an answer
      # as selected.
      class UpdateAnswerSelection < Decidim::Command
        def initialize(answer, selected)
          @answer = answer
          @selected = selected
        end

        # Selects the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          update_answer_selection!

          broadcast(:ok, answer)
        end

        private

        attr_reader :answer, :selected

        def invalid?
          !answer.question.results_total.positive?
        end

        def update_answer_selection!
          answer.update!(
            selected:
          )
        end
      end
    end
  end
end
