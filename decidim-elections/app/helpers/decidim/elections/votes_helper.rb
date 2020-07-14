# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for the voting booth views.
    #
    module VotesHelper
      def ordered_answers(question)
        if question.random_answers_order
          question.answers.shuffle
        else
          question.answers
        end
      end

      def more_information?(answer)
        answer.description || answer.proposals.any? || answer.photos.any?
      end
    end
  end
end
