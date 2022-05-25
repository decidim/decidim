# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user answers a Questionnaire.
    class AnswerQuestionnaire < Decidim::Command
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
        return broadcast(:invalid) if @form.invalid? || user_already_answered?

        answer_questionnaire

        if @errors
          reset_form_attachments
          broadcast(:invalid)
        else
          broadcast(:ok)
        end
      end

      attr_reader :form, :questionnaire, :current_user

      private

      # This method will add an error to the `add_documents` field only if there's
      # any error in any other field or an error in another answer in the
      # questionnaire. This is needed because when the form has
      # an error, the attachments are lost, so we need a way to inform the user
      # of this problem.
      def reset_form_attachments
        @form.responses.each do |answer|
          answer.errors.add(:add_documents, :needs_to_be_reattached) if answer.has_attachments? || answer.has_error_in_attachments?
        end
      end

      def answer_questionnaire
        @main_form = @form
        @errors = nil

        Answer.transaction(requires_new: true) do
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

            next unless form_answer.question.has_attachments?

            # The attachments module expects `@form` to be the form with the
            # attachments
            @form = form_answer
            @attached_to = answer

            build_attachments

            if attachments_invalid?
              @errors = true
              next
            end

            create_attachments if process_attachments?
            document_cleanup!
          end

          @form = @main_form
          raise ActiveRecord::Rollback if @errors
        end
      end

      def user_already_answered?
        questionnaire.answered_by?(current_user || form.context.session_token)
      end
    end
  end
end
