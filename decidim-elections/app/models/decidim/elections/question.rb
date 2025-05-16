# frozen_string_literal: true

module Decidim
  module Elections
    class Question < ApplicationRecord
      include Decidim::TranslatableResource

      QUESTION_TYPES = %w(single_option multiple_option).freeze

      belongs_to :questionnaire, class_name: "Decidim::Elections::Questionnaire", inverse_of: :questions

      has_many :answers, class_name: "Decidim::Elections::Answer", inverse_of: :question, dependent: :destroy

      delegate :organization, to: :questionnaire

      translatable_fields :body, :description

      validates :body, presence: true
    end
  end
end
