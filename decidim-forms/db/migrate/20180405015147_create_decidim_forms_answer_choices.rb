# frozen_string_literal: true

class CreateDecidimFormsAnswerChoices < ActiveRecord::Migration[5.1]
  class Answer < ApplicationRecord
    self.table_name = :decidim_forms_answers
  end

  class AnswerChoice < ApplicationRecord
    self.table_name = :decidim_forms_answer_choices
  end

  class Question < ApplicationRecord
    self.table_name = :decidim_forms_questions
  end

  class AnswerOption < ApplicationRecord
    self.table_name = :decidim_forms_answer_options
  end

  def up
    create_table :decidim_forms_answer_choices do |t|
      t.references :decidim_answer, index: { name: "index_decidim_forms_answer_choices_answer_id" }
      t.references :decidim_answer_option, index: { name: "index_decidim_forms_answer_choices_answer_option_id" }
      t.jsonb :body
    end

    Answer.find_each do |answer|
      question = Question.find_by(id: answer.decidim_question_id)
      choices = AnswerChoice.where(decidim_answer_id: answer.id)

      choices.each do |answer_choice|
        answer_options = AnswerOption.where(decidim_question_id: question.id)

        answer_option = answer_options.find do |option|
          option.body.has_value?(answer_choice)
        end

        AnswerChoice.create!(
          decidim_answer_id: answer.id,
          decidim_answer_option_id: answer_option.id,
          body: answer_choice
        )
      end
    end

    remove_column :decidim_forms_answers, :choices
  end

  def down
    add_column :decidim_forms_answers, :choices, :jsonb, default: []

    AnswerChoice.find_each do |answer_choice|
      answer = Answer.find_by(id: answer_choice.decidim_answer_id)

      answer.choices << answer_choice.body

      answer.save!
    end

    drop_table :decidim_forms_answer_choices
  end
end
