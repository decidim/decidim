# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class QuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :position, Integer
        attribute :mandatory, Boolean, default: false
        attribute :question_type, String
        attribute :response_options, Array[ResponseOptionForm]
        attribute :max_choices, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: Decidim::Meetings::Question::QUESTION_TYPES }, if: :editable?
        validates :max_choices, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: ->(form) { form.number_of_options } }, allow_blank: true, if: :editable?
        validates :body, translatable_presence: true, if: :requires_body?
        validates :response_options, presence: true, if: :editable?

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def editable?
          @editable ||= id.blank? || Decidim::Meetings::Question.unpublished.unanswered.exists?(id:)
        end

        def number_of_options
          response_options.size
        end

        private

        def requires_body?
          editable? && !deleted
        end
      end
    end
  end
end
