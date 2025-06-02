# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionForm < Decidim::Form
        mimic :question

        include TranslatableAttributes

        attribute :mandatory, Boolean, default: false
        attribute :question_type, String, default: "multiple_option"
        attribute :position, Integer, default: 1
        attribute :response_options, Array[Decidim::Elections::Admin::ResponseOptionForm]
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :body, translatable_presence: true
        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: Decidim::Elections::Question::QUESTION_TYPES }, if: :editable?
        validates :response_options, presence: true, if: :editable?

        def election
          @election ||= context[:election]
        end

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def editable?
          @editable ||= id.blank? || Decidim::Elections::Question.exists?(id:)
        end

        def number_of_options
          response_options.size
        end
      end
    end
  end
end
