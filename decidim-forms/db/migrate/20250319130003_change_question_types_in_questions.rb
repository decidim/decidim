# frozen_string_literal: true

class ChangeQuestionTypesInQuestions < ActiveRecord::Migration[7.0]
  class Question < ApplicationRecord
    self.table_name = :decidim_forms_questions
  end

  def change
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Forms::Question.where(question_type: "short_answer").update_all(question_type: "short_response")
    Decidim::Forms::Question.where(question_type: "long_answer").update_all(question_type: "long_response")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
