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

        translatable_attribute :statement, String
        translatable_attribute :description, String

        validates :statement, translatable_presence: true

        def election
          @election ||= context[:election]
        end

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def question_types_for_select
          Decidim::Elections::Question::QUESTION_TYPES.map do |type|
            [
              I18n.t(type.downcase, scope: "decidim.elections.admin.questions.form.question_types"),
              type
            ]
          end
        end
      end
    end
  end
end
