# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class CopySurvey < Rectify::Command
        # Initializes a CopySurvey Command.
        def initialize(component, origin = nil)
          @component = component
          @origin = origin
        end

        # Updates the survey if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          Survey.transaction do
            @survey = Survey.new(component: @component)
            unless @origin.nil?
              copy_survey_questions unless @origin.questions.empty?
              update_survey
            end
            @survey.save!
          end

          broadcast(:ok)
        end

        private

        def copy_survey_questions
          @origin.questions.each do |question|
            new_question = question.dup
            new_question.survey = @survey
            question.answer_options.each do |answer_option|
              new_answer_option = answer_option.dup
              new_answer_option.question = new_question
              new_answer_option.save!
            end

            new_question.save!
          end
        end

        def update_survey
          @survey.title = @origin.title
          @survey.description = @origin.description
          @survey.tos = @origin.tos
          @survey.save!
        end
      end
    end
  end
end
