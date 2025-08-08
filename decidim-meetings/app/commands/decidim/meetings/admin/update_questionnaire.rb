# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Questionnaire from the admin
      # panel.
      class UpdateQuestionnaire < Decidim::Command
        # Initializes a UpdateQuestionnaire Command.
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

          Decidim.traceability.perform_action!("update", Decidim::Meetings::Questionnaire, @form.current_user, { meeting: @questionnaire.questionnaire_for.try(:meeting) }) do
            Decidim::Meetings::Questionnaire.transaction do
              create_questionnaire_for
              create_questionnaire
              update_questionnaire_questions
              @questionnaire
            end
          end

          broadcast(:ok)
        end

        private

        def create_questionnaire_for
          @questionnaire.questionnaire_for.save! if @questionnaire.questionnaire_for.new_record?
        end

        def create_questionnaire
          @questionnaire.save! if @questionnaire.new_record?
        end

        def update_questionnaire_questions
          @form.questions.each do |form_question|
            if form_question.editable?
              update_questionnaire_question(form_question)
            else
              update_questionnaire_question_position(form_question)
            end
          end
        end

        def update_questionnaire_question_position(form_question)
          record = @questionnaire.questions.find_by(id: form_question.id)
          return if record.blank?

          position = form_question.position

          return if position == record.position

          record.update!(position:)
        end

        def update_questionnaire_question(form_question)
          question_attributes = {
            body: form_question.body,
            position: form_question.position,
            question_type: form_question.question_type,
            max_choices: form_question.max_choices
          }

          update_nested_model(form_question, question_attributes, @questionnaire.questions) do |question|
            form_question.response_options.each do |form_response_option|
              response_option_attributes = {
                body: form_response_option.body
              }

              update_nested_model(form_response_option, response_option_attributes, question.response_options)
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
