# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Questionnaire from the admin panel.
      class CreateQuestionnaire < Rectify::Command
        # Initializes an CreateQuestionnaire Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the meeting where create the questionnaire.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_questionnaire!
            create_questions!
          end

          broadcast(:ok, @questionnaire)
        end

        private

        def create_questionnaire!
          @questionnaire = Decidim.traceability.create!(
            Questionnaire,
            @form.current_user,
            meeting: @meeting,
            questionnaire_type: @form.questionnaire_type,
            title: @form.title,
            description: @form.description,
            tos: @form.tos
          )
        end

        def create_questions!
          @form.questions_to_persist.each do |form_question|
            question = @questionnaire.questions.build(
              body: form_question.body,
              description: form_question.description,
              position: form_question.position,
              mandatory: form_question.mandatory,
              question_type: form_question.question_type,
              max_choices: form_question.max_choices,
            )

            form_question.options_to_persist.each do |form_answer_option|
              question.answer_options.build(
                body: form_answer_option.body,
                free_text: form_answer_option.free_text
              )
            end

            question.save!
          end
        end
      end
    end
  end
end
