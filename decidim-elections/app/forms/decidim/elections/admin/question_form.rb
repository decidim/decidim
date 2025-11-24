# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionForm < Decidim::Form
        mimic :question

        include TranslatableAttributes

        attribute :question_type, String, default: "multiple_option"
        attribute :response_options, Array[Decidim::Elections::Admin::ResponseOptionForm]
        attribute :max_choices, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :body, translatable_presence: true
        validates :question_type, inclusion: { in: Decidim::Elections::Question.question_types }, if: :editable?
        validates :response_options, presence: true, if: :editable?
        validates :max_choices, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: ->(form) { form.number_of_options } }, allow_blank: true

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
