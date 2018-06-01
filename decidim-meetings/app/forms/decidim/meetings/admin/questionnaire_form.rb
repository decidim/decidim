# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update questionnaires from Decidim's admin panel.
      class QuestionnaireForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :tos, String

        attribute :questionnaire_type, String
        attribute :questions, Array[QuestionnaireQuestionForm]

        validates :title, :tos, translatable_presence: true
        validates :questionnaire_type, presence: true, inclusion: { in: Questionnaire::TYPES }, unless: :persisted?

        def map_model(model)
          self.questions = model.questions.map do |question|
            QuestionnaireQuestionForm.from_model(question)
          end
        end

        def can_edit_questions?
          answers.empty?
        end

        def number_of_questions
          questions.size
        end

        def questions_to_persist
          questions.reject(&:deleted)
        end

        private

        def answers
          @answers ||= Decidim::Meetings::QuestionnaireAnswer.where(questionnaire: id)
        end
      end
    end
  end
end
