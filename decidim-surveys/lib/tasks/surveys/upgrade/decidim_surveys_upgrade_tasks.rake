# frozen_string_literal: true

namespace :decidim_surveys do
  namespace :upgrade do
    desc "Migrates data from decidim_surveys tables to decidim_forms tables"
    task migrate_data_to_decidim_forms: :environment do
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

      unless [Answer, AnswerChoice, AnswerOption, Question].all? { |model| ActiveRecord::Base.connection.table_exists? model.table_name }
        puts "ERROR: There are not all the necessary surveys tables. Have you already migrated the data?"
        next
      end

      ActiveRecord::Base.transaction do
        Decidim::Surveys::Survey.find_each do |survey|
          puts "Migrating survey #{survey.id}..."

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
            puts "Migrating question #{survey_question.id}..."

            question = Decidim::Forms::Question.create!(
              questionnaire:,
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
                question:,
                body: survey_answer_option.body,
                free_text: survey_answer_option.free_text
              )
            end

            Answer.where(decidim_survey_id: survey.id, decidim_survey_question_id: survey_question.id).find_each do |survey_answer|
              answer = Decidim::Forms::Answer.new(
                questionnaire:,
                question:,
                decidim_user_id: survey_answer.decidim_user_id,
                body: survey_answer.body,
                created_at: survey_answer.created_at,
                updated_at: survey_answer.updated_at
              )

              AnswerChoice.where(decidim_survey_answer_id: survey_answer.id).find_each do |survey_answer_choice|
                answer.choices.build(
                  answer_option: answer_option_mapping[survey_answer_choice.decidim_survey_answer_option_id],
                  body: survey_answer_choice.body,
                  custom_body: survey_answer_choice.custom_body,
                  position: survey_answer_choice.position
                )
              end

              answer.save!
            end
          end
        end
      end
    end
  end
end
