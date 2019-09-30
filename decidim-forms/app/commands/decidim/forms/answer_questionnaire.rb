# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user answers a Questionnaire.
    class AnswerQuestionnaire < Rectify::Command
      # Initializes a AnswerQuestionnaire Command.
      #
      # form - The form from which to get the data.
      # questionnaire - The current instance of the questionnaire to be answered.
      # request - a request object is needed if belongs to and unregistered user survey
      def initialize(form, current_user, questionnaire, request = nil)
        @form = form
        @current_user = current_user
        @questionnaire = questionnaire
        @request = request
      end

      # Answers a questionnaire if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        # if no user, we need an ip to tokenize
        unless @current_user
          return broadcast(:invalid) unless ip_hash
        end

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
              session_token: session_token,
              ip_hash: ip_hash
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

      def ip_hash
        return nil unless @request&.remote_ip

        @ip_hash ||= tokenize(@request&.remote_ip)
      end

      def session_token
        session_id = @request.session[:session_id] if @request&.session
        @session_token ||= tokenize(session_id || @current_user&.id || Time.now.to_i)
      end

      def tokenize(id)
        Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
      end
    end
  end
end
