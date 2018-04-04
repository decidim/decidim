# frozen_string_literal: true

class CreateDecidimSurveyAnswerChoices < ActiveRecord::Migration[5.1]
  class SurveyAnswer < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answers
  end

  class SurveyAnswerChoice < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_choices
  end

  def up
    create_table :decidim_surveys_survey_answer_choices do |t|
      t.references :decidim_survey_answer, index: { name: "index_decidim_surveys_answer_choices_answer_id" }
      t.references :decidim_survey_answer_option, index: { name: "index_decidim_surveys_answer_choices_answer_option_id" }
      t.jsonb :body
    end

    SurveyAnswer.find_each do |answer|
      next if %(short_answer long_answer).include?(answer.question.question_type)

      answer.body.each do |answer_choice|
        answer_option = answer.question.answer_options.find do |option|
          option.body.values.include?(answer_choice)
        end

        SurveyAnswerChoice.create!(
          decidim_survey_answer_id: answer.id,
          decidim_survey_answer_option_id: answer_option.id,
          body: answer_choice
        )
      end
    end
  end

  def down
    SurveyAnswerChoice.find_each do |answer_choice|
      answer = answer_choice.answer

      answer.body << answer_choice.body

      answer.save!
    end

    drop_table :decidim_surveys_survey_answer_choices
  end
end
