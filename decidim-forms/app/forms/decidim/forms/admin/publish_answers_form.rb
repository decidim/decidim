# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to publish answers from Decidim's admin panel.
      class PublishAnswersForm < Decidim::Form
        include TranslatableAttributes

        attribute :question_ids, Array[Integer]
        attribute :questionnaire, Decidim::Forms::Questionnaire

        IGNORED_QUESTION_TYPES = %w(separator files).freeze

        def map_model(model)
          self.question_ids = model.questionnaire.questions.map(&:id)
          self.questionnaire = model.questionnaire
        end

        def questions
          questionnaire.questions
                       &.select(:body, :question_type, :id)
                       &.reject { |q| IGNORED_QUESTION_TYPES.include?(q.question_type) }
                       &.map do |q|
            QuestionStruct.new(
              name: label_for_question(q),
              value: q.id
            )
          end
        end

        def question_checked?(question_id)
          questionnaire.questions.find(question_id).survey_answers_published_at.present?
        end

        def published_answers?
          questionnaire.questions.any? { |q| q.survey_answers_published_at.present? }
        end

        private

        def label_for_question(question)
          "#{question.body[I18n.locale.to_s]} (#{question.question_type})"
        end

        class QuestionStruct
          def initialize(name:, value:)
            @name = name
            @value = value
          end

          attr_reader :name, :value
        end
      end
    end
  end
end
