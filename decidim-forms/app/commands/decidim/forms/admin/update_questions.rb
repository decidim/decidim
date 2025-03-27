# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This command is executed when the user changes a Questionnaire questions from the admin
      # panel.
      class UpdateQuestions < Decidim::Command
        # Initializes a UpdateQuestions Command.
        #
        # form - The form from which to get the data.
        # questionnaire - The current instance of the questionnaire questions to be updated.
        def initialize(form, questionnaire)
          @form = form
          @questionnaire = questionnaire
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Decidim.traceability.perform_action!("update",
                                               @questionnaire,
                                               @form.current_user) do
            Decidim::Forms::Questionnaire.transaction do
              update_questionnaire_questions if @questionnaire.questions_editable?
            end
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
            max_choices: form_question.max_choices,
            max_characters: form_question.max_characters
          }

          update_nested_model(form_question, question_attributes, @questionnaire.questions) do |question|
            form_question.response_options.each do |form_response_option|
              response_option_attributes = {
                body: form_response_option.body,
                free_text: form_response_option.free_text
              }

              update_nested_model(form_response_option, response_option_attributes, question.response_options)
            end

            form_question.display_conditions.each do |form_display_condition|
              type = form_display_condition.condition_type

              display_condition_attributes = {
                condition_question: form_display_condition.condition_question,
                condition_type: form_display_condition.condition_type,
                condition_value: type == "match" ? form_display_condition.condition_value : nil,
                response_option: %w(equal not_equal).include?(type) ? form_display_condition.response_option : nil,
                mandatory: form_display_condition.mandatory
              }

              next if form_display_condition.deleted? && form_display_condition.id.blank?

              update_nested_model(form_display_condition, display_condition_attributes, question.display_conditions)
            end

            form_question.matrix_rows_by_position.each_with_index do |form_matrix_row, idx|
              matrix_row_attributes = {
                body: form_matrix_row.body,
                position: form_matrix_row.position || idx
              }

              update_nested_model(form_matrix_row, matrix_row_attributes, question.matrix_rows)
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
      end
    end
  end
end
