# frozen_string_literal: true

class AddQuestionTypeToFormsQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_forms_questions, :question_type, :string
  end
end
