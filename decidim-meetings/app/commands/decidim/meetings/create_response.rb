# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user creates an Response in a meeting poll.
    class CreateResponse < Decidim::Command
      delegate :current_user, to: :form

      def initialize(form, questionnaire)
        @form = form
        @questionnaire = questionnaire
      end

      # Creates the response if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        @question = @questionnaire.questions.find_by(id: form.question_id)
        return broadcast(:invalid) unless question

        form.question = question
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless response_options_valid?

        transaction do
          response_question
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :question, :response

      def invalid?
        form.invalid?
      end

      def response_question
        response = Response.new(
          user: current_user,
          questionnaire: @questionnaire,
          question:
        )

        form.selected_choices.each do |choice|
          response_option = question.response_options.find(choice.response_option_id)

          response.choices.build(
            body: choice.body || translated_attribute(response_option.body),
            decidim_response_option_id: response_option.id
          )
        end

        response.save!
      end

      def response_options_valid?
        form.selected_choices.all? do |choice|
          next true if question.response_options.exists?(id: choice.response_option_id)

          form.errors.add(:choices, :invalid)
          false
        end
      end
    end
  end
end
