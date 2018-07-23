# frozen_string_literal: true

class CreateDecidimFormsAnswerOptions < ActiveRecord::Migration[5.1]
  class Question < ApplicationRecord
    self.table_name = :decidim_forms_questions
  end

  class AnswerOption < ApplicationRecord
    self.table_name = :decidim_forms_answer_options
  end

  def up
    create_table :decidim_forms_answer_options do |t|
      t.references :decidim_question, index: { name: "index_decidim_forms_answer_options_question_id" }
      t.jsonb :body
    end

    Question.find_each do |question|
      question.answer_options.each do |answer_option|
        AnswerOption.create!(
          decidim_question_id: question.id,
          body: answer_option["body"]
        )
      end
    end

    remove_column :decidim_forms_questions, :answer_options
  end

  def down
    add_column :decidim_forms_questions, :answer_options, :jsonb, default: []

    AnswerOption.find_each do |answer_option|
      question = Question.find(answer_option.decidim_question_id)

      question.answer_options << { "body" => answer_option.body }

      question.save!
    end

    drop_table :decidim_forms_answer_options
  end
end
