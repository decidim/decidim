# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user answers a Questionnaire.
    class AnswerQuestionnaire < Rectify::Command
      # Initializes a AnswerQuestionnaire Command.
      #
      # form - The form from which to get the data.
      # questionnaire - The current instance of the questionnaire to be answered.
      def initialize(form, current_user, questionnaire, session_token = nil)
        @form = form
        @current_user = current_user
        @questionnaire = questionnaire
        @session_token = session_token || session_token(current_user&.id || Time.now.to_i)
      end

      # Answers a questionnaire if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        answer_questionnaire
        broadcast(:ok)
      end

      private

      def answer_questionnaire
        Answer.transaction do
          @form.answers.each do |form_answer|
            answer = Answer.new(
              user: @current_user,
              questionnaire: @questionnaire,
              question: form_answer.question,
              body: form_answer.body,
              session_token: @session_token
            )

            form_answer.selected_choices.each do |choice|
              answer.choices.build(
                body: choice.body,
                custom_body: choice.custom_body,
                decidim_answer_option_id: choice.answer_option_id,
                position: choice.position
              )
            end

            answer.save!
          end
        end
      end

      def session_token(id)
        @session_token ||= Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
      end
    end
  end
end
