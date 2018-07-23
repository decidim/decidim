# frozen_string_literal: true

class AddChoicesToDecidimFormsAnswers < ActiveRecord::Migration[5.1]
  class Answer < ApplicationRecord
    self.table_name = :decidim_forms_answers
  end

  class Question < ApplicationRecord
    self.table_name = :decidim_forms_questions
  end

  def up
    add_column :decidim_forms_answers, :text_body, :text
    add_column :decidim_forms_answers, :choices, :jsonb, default: []

    Answer.find_each do |answer|
      question = Question.find_by(id: answer.decidim_question_id)

      if %w(single_option multiple_option).include?(question.question_type)
        answer.update!(choices: answer.body)
      else
        answer.update!(text_body: answer.body.first)
      end
    end

    remove_column :decidim_forms_answers, :body
    rename_column :decidim_forms_answers, :text_body, :body
  end

  def down
    add_column :decidim_forms_answers, :jsonb_body, :jsonb, default: []

    Answer.find_each do |answer|
      question = Question.find_by(id: answer.decidim_question_id)

      if %w(single_option multiple_option).include?(question.question_type)
        answer.update!(jsonb_body: answer.choices)
      else
        answer.update!(jsonb_body: [answer.body])
      end
    end

    remove_column :decidim_forms_answers, :choices

    remove_column :decidim_forms_answers, :body
    rename_column :decidim_forms_answers, :jsonb_body, :body
  end
end
