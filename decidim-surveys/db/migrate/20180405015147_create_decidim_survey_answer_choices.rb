# frozen_string_literal: true

class CreateDecidimSurveyAnswerChoices < ActiveRecord::Migration[5.1]
  class SurveyAnswer < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answers
  end

  class SurveyAnswerChoice < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_choices
  end

  class SurveyQuestion < ApplicationRecord
    self.table_name = :decidim_surveys_survey_questions
  end

  class SurveyAnswerOption < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_options
  end

  def up
    create_table :decidim_surveys_survey_answer_choices do |t|
      t.references :decidim_survey_answer, index: { name: "index_decidim_surveys_answer_choices_answer_id" }
      t.references :decidim_survey_answer_option, index: { name: "index_decidim_surveys_answer_choices_answer_option_id" }
      t.jsonb :body
    end

    SurveyAnswer.find_each do |answer|
      question = SurveyQuestion.find_by(id: answer.decidim_survey_question_id)
      choices = SurveyAnswerChoice.where(decidim_survey_answer_id: answer.id)

      choices.each do |answer_choice|
        answer_options = SurveyAnswerOption.where(decidim_survey_question_id: question.id)

        answer_option = answer_options.find do |option|
          option.body.has_value?(answer_choice)
        end

        SurveyAnswerChoice.create!(
          decidim_survey_answer_id: answer.id,
          decidim_survey_answer_option_id: answer_option.id,
          body: answer_choice
        )
      end
    end

    remove_column :decidim_surveys_survey_answers, :choices
  end

  def down
    add_column :decidim_surveys_survey_answers, :choices, :jsonb, default: []

    SurveyAnswerChoice.find_each do |answer_choice|
      answer = SurveyAnswer.find_by(id: answer_choice.decidim_survey_answer_id)

      answer.choices << answer_choice.body

      answer.save!
    end

    drop_table :decidim_surveys_survey_answer_choices
  end
end
