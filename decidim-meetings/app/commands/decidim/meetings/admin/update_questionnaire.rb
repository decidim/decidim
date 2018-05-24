# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Questionnaire from the admin panel.
      class UpdateQuestionnaire < Rectify::Command
        # Initializes an UpdateQuestionnaire Command.
        #
        # form - The form from which to get the data.
        # questionnaire - The current instance of the questionnaire to be updated.
        def initialize(form, questionnaire)
          @form = form
          @questionnaire = questionnaire
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Questionnaire.transaction do
            update_questionnaire_questions if @questionnaire.questions_editable?
            update_questionnaire
          end

          broadcast(:ok)
        end

        private

        def update_questionnaire_questions
          @form.questions.each do |form_question|
            update_questionnaire_question(form_question)
          end
        end

        def update_questionnaire_question(form_question)
          question_attributes = {
            body: form_question.body,
            description: form_question.description,
            position: form_question.position,
            mandatory: form_question.mandatory,
            question_type: form_question.question_type,
            max_choices: form_question.max_choices
          }

          update_nested_model(form_question, question_attributes, @questionnaire.questions) do |question|
            form_question.answer_options.each do |form_answer_option|
              answer_option_attributes = {
                body: form_answer_option.body,
                free_text: form_answer_option.free_text
              }

              update_nested_model(form_answer_option, answer_option_attributes, question.answer_options)
            end
          end
        end

        def update_nested_model(form, attributes, parent_association)
          record = parent_association.find_by(id: form.id) || parent_association.build(attributes)

          yield record if block_given?

          if record.persisted?
            if form.deleted?
              record.destroy!
            else
              record.update!(attributes)
            end
          else
            record.save!
          end
        end

        def update_questionnaire
          @questionnaire.update!(title: @form.title,
                          description: @form.description,
                          tos: @form.tos)
        end
      end
    end
  end
end
