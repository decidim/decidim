# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the percentage of responses which chose
    # the given answer option in a meeting poll question
    class QuestionResponsesCell < Decidim::ViewModel
      include ActionView::Helpers::NumberHelper

      def show
        render
      end

      private

      def answer_percentage
        total = answers.count
        option = answers.where(decidim_answer_option_id: model.id).count
        "#{number_with_precision(calculate_percentage(option, total), precision: 1, significant: true)}%"
      end

      def calculate_percentage(part, total)
        total.zero? ? 0 : (part.to_f / total) * 100
      end

      def answers
        @answers ||= Decidim::Meetings::AnswerChoice.joins(:answer).where("#{Decidim::Meetings::Answer.table_name}.decidim_question_id" => model.question.id)
      end
    end
  end
end
