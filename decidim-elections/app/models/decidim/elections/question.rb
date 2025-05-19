# frozen_string_literal: true

module Decidim
  module Elections
    class Question < ApplicationRecord
      include Decidim::TranslatableResource

      QUESTION_TYPES = %w(single_option multiple_option).freeze

      belongs_to :questionnaire, class_name: "Decidim::Elections::Questionnaire", foreign_key: :decidim_questionnaire_id, inverse_of: :questions

      has_many :response_options, class_name: "Decidim::Elections::ResponseOption", foreign_key: "decidim_question_id", dependent: :destroy, inverse_of: :question

      validates :question_type, inclusion: { in: QUESTION_TYPES }

      translatable_fields :body, :description

      validates :body, presence: true

      def translated_body
        Decidim::Forms::QuestionPresenter.new(self).translated_body
      end

      def number_of_options
        response_options.size
      end
    end
  end
end
