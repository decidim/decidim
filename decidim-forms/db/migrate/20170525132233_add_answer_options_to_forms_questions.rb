# frozen_string_literal: true

class AddAnswerOptionsToFormsQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_forms_questions, :answer_options, :jsonb, default: []
  end
end
