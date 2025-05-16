# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionForm < Decidim::Form
        mimic :question

        include TranslatableAttributes

        attribute :mandatory, Boolean, default: false
        attribute :question_type, String, default: "multiple_option"
        attribute :position, Integer
        attribute :answers, Array[AnswerForm]
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :body, translatable_presence: true
        validates :position, numericality: { greater_than_or_equal_to: 0 }

        def election
          @election ||= context[:election]
        end

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def editable?
          # TODO: Needs to be changed
          @editable ||= id.blank? || Decidim::Elections::Question.where(id: id)
        end
      end
    end
  end
end
