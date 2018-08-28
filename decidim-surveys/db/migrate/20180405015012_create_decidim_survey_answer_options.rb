# frozen_string_literal: true

class CreateDecidimSurveyAnswerOptions < ActiveRecord::Migration[5.1]
  class SurveyQuestion < ApplicationRecord
    self.table_name = :decidim_surveys_survey_questions
  end

  class SurveyAnswerOption < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_options
  end

  def up
    create_table :decidim_surveys_survey_answer_options do |t|
      t.references :decidim_survey_question, index: { name: "index_decidim_surveys_answer_options_question_id" }
      t.jsonb :body
    end

    SurveyQuestion.find_each do |question|
      question.answer_options.each do |answer_option|
        SurveyAnswerOption.create!(
          decidim_survey_question_id: question.id,
          body: answer_option["body"]
        )
      end
    end

    remove_column :decidim_surveys_survey_questions, :answer_options
  end

  def down
    add_column :decidim_surveys_survey_questions, :answer_options, :jsonb, default: []

    SurveyAnswerOption.find_each do |answer_option|
      question = SurveyQuestion.find(answer_option.decidim_survey_question_id)

      question.answer_options << { "body" => answer_option.body }

      question.save!
    end

    drop_table :decidim_surveys_survey_answer_options
  end
end
