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
        return broadcast(:invalid) if form.invalid?

        transaction do
          response_question
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :response

      def invalid?
        form.invalid?
      end

      def response_question
        response = Response.new(
          user: current_user,
          questionnaire: @questionnaire,
          question: form.question
        )

        form.selected_choices.each do |choice|
          response.choices.build(
            body: choice.body || translated_attribute(ResponseOption.find_by(id: choice.response_option_id)&.body),
            decidim_response_option_id: choice.response_option_id
          )
        end

        response.save!
      end
    end
  end
end
