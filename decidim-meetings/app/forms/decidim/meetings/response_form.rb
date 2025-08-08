# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to save the questionnaire responses from Decidim's public page
    class ResponseForm < Decidim::Form
      include Decidim::TranslationsHelper

      attribute :question_id, String
      attribute :body, String
      attribute :choices, Array[ResponseChoiceForm]
      attribute :current_user, Decidim::User

      validates :selected_choices, presence: true
      validate :max_choices, if: -> { question.max_choices }

      attr_writer :question

      def question
        @question ||= Decidim::Meetings::Question.find(question_id)
      end

      def response
        @response ||= Decidim::Meetings::Response.find_by(decidim_user_id: current_user.id, decidim_question_id: question_id) if current_user
      end

      def label
        base = translated_attribute(question.body)
        base += " (#{max_choices_label})" if question.max_choices
        base
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.decidim_question_id
        self.question = model.question

        self.choices = model.choices.map do |choice|
          ResponseChoiceForm.from_model(choice)
        end
      end

      def selected_choices
        choices.select(&:response_option_id)
      end

      private

      def max_choices
        errors.add(:choices, :too_many, count: question.max_choices) if selected_choices.size > question.max_choices
      end

      def mandatory_label
        "*"
      end

      def max_choices_label
        I18n.t("questionnaires.question.max_choices", scope: "decidim.forms", n: question.max_choices)
      end
    end
  end
end
