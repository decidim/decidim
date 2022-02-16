# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user creates an Answer in a meeting poll.
    class CreateAnswer < Decidim::Command
      def initialize(form, current_user, questionnaire)
        @form = form
        @current_user = current_user
        @questionnaire = questionnaire
      end

      # Creates the answer if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          answer_question
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :answer

      def invalid?
        form.invalid?
      end

      def answer_question
        answer = Answer.new(
          user: @current_user,
          questionnaire: @questionnaire,
          question: form.question
        )

        form.selected_choices.each do |choice|
          answer.choices.build(
            body: choice.body,
            decidim_answer_option_id: choice.answer_option_id
          )
        end

        answer.save!
      end
    end
  end
end
