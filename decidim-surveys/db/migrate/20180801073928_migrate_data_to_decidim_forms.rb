# frozen_string_literal: true

class MigrateDataToDecidimForms < ActiveRecord::Migration[5.2]
  class Answer < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answers
  end

  class AnswerChoice < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_choices
  end

  class AnswerOption < ApplicationRecord
    self.table_name = :decidim_surveys_survey_answer_options
  end

  class Question < ApplicationRecord
    self.table_name = :decidim_surveys_survey_questions
  end

  def up
    return unless [Answer, AnswerChoice, AnswerOption, Question].all? { |model| table_exists? model.table_name }

    Decidim::Surveys::Survey.find_each do |survey|
      questionnaire = Decidim::Forms::Questionnaire.create!(
        questionnaire_for: survey,
        title: survey.title,
        description: survey.description,
        tos: survey.tos,
        published_at: survey.published_at,
        created_at: survey.created_at,
        updated_at: survey.updated_at
      )

      Question.where(decidim_survey_id: survey.id).find_each do |survey_question|
        question = Decidim::Forms::Question.create!(
          questionnaire: questionnaire,
          position: survey_question.position,
          question_type: survey_question.question_type,
          mandatory: survey_question.mandatory,
          body: survey_question.body,
          description: survey_question.description,
          max_choices: survey_question.max_choices,
          created_at: survey_question.created_at,
          updated_at: survey_question.updated_at
        )

        # A hash with the old answer_option id as key, and the new form answer option as value
        answer_option_mapping = {}

        AnswerOption.where(decidim_survey_question_id: survey_question.id).find_each do |survey_answer_option|
          answer_option_mapping[survey_answer_option.id] = Decidim::Forms::AnswerOption.create!(
            question: question,
            body: survey_answer_option.body,
            free_text: survey_answer_option.free_text
          )
        end

        Answer.where(decidim_survey_id: survey.id, decidim_survey_question_id: survey_question.id).find_each do |survey_answer|
          answer = Decidim::Forms::Answer.create!(
            questionnaire: questionnaire,
            question: question,
            decidim_user_id: survey_answer.decidim_user_id,
            body: survey_answer.body,
            created_at: survey_answer.created_at,
            updated_at: survey_answer.updated_at
          )

          AnswerChoice.where(decidim_survey_answer_id: survey_answer.id).find_each do |survey_answer_choice|
            Decidim::Forms::AnswerChoice.create!(
              answer: answer,
              answer_option: answer_option_mapping[survey_answer_choice.decidim_survey_answer_option_id],
              body: survey_answer_choice.body,
              custom_body: survey_answer_choice.custom_body,
              position: survey_answer_choice.position
            )
          end
        end
      end
    end

    # Drop tables
    drop_table Answer.table_name
    drop_table AnswerChoice.table_name
    drop_table AnswerOption.table_name
    drop_table Question.table_name

    # Drop columns from surveys table
    remove_column :decidim_surveys_surveys, :title
    remove_column :decidim_surveys_surveys, :description
    remove_column :decidim_surveys_surveys, :tos
    remove_column :decidim_surveys_surveys, :published_at
  end
end
