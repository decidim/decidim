# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user answers a Questionnaire.
    class AnswerQuestionnaire < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Initializes a AnswerQuestionnaire Command.
      #
      # form - The form from which to get the data.
      # questionnaire - The current instance of the questionnaire to be answered.
      def initialize(form, current_user, questionnaire)
        @form = form
        @current_user = current_user
        @questionnaire = questionnaire
      end

      # Answers a questionnaire if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        answer_questionnaire
        broadcast(:ok)
      end

      attr_reader :form

      private

      def answer_questionnaire
        Answer.transaction do
          form.responses_by_step.flatten.select(&:display_conditions_fulfilled?).each do |form_answer|
            answer = Answer.new(
              user: @current_user,
              questionnaire: @questionnaire,
              question: form_answer.question,
              body: form_answer.body,
              session_token: form.context.session_token,
              ip_hash: form.context.ip_hash
            )

            form_answer.selected_choices.each do |choice|
              answer.choices.build(
                body: choice.body,
                custom_body: choice.custom_body,
                decidim_answer_option_id: choice.answer_option_id,
                decidim_question_matrix_row_id: choice.matrix_row_id,
                position: choice.position
              )
            end

            answer.save!
            @main_form = @form

            if form_answer.question.has_attachments?
              # The attachments module expects `@form` to be the form with the
              # attachments
              @form = form_answer
              @attached_to = answer
              build_attachments
              return broadcast(:invalid) if attachments_invalid?
              create_attachments if process_attachments?
              document_cleanup!
            end

            @form = @main_form
          end
        end
      end
    end
  end
end
