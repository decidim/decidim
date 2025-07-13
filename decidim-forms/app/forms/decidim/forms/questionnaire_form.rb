# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to response a questionnaire from Decidim's public page.
    class QuestionnaireForm < Decidim::Form
      include ActiveModel::Validations::Callbacks

      # as questionnaire uses "responses" for the database relationships is
      # important not to use the same word here to avoid querying all the entries, resulting in a high performance penalty
      attribute :responses, Array[ResponseForm]
      attribute :public_participation, Boolean, default: false

      attribute :tos_agreement, Boolean
      attribute :allow_editing_responses, Boolean, default: false

      before_validation :before_validation

      validates :tos_agreement, allow_nil: false, acceptance: true
      validate :session_token_in_context

      # Private: Create the responses from the questionnaire questions
      #
      # Returns nothing.
      def map_model(model)
        self.responses = model.questions.map do |question|
          ResponseForm.from_model(Decidim::Forms::Response.new(question:))
        end
      end

      def add_responses!(questionnaire:, session_token:, ip_hash:)
        self.responses = questionnaire.questions.map do |question|
          ResponseForm.from_model(Decidim::Forms::Response.where(question:, user: current_user, session_token:, ip_hash:).first_or_initialize)
        end
      end

      # Add other responses to the context so ResponseForm can validate conditional questions
      def before_validation
        context.responses = attributes[:responses]
      end

      # Public: Splits responses by step, keeping the separator.
      #
      # Returns an array of steps. Each step is a list of the questions in that
      # step, including the separator.
      def responses_by_step
        @responses_by_step ||=
          begin
            steps = responses.chunk_while do |a, b|
              !a.question.separator? || b.question.separator?
            end.to_a

            steps = [[]] if steps == []
            steps
          end
      end

      def total_steps
        responses_by_step.count
      end

      def session_token_in_context
        return if context&.session_token

        errors.add(:tos_agreement, I18n.t("activemodel.errors.models.questionnaire.request_invalid"))
      end
    end
  end
end
