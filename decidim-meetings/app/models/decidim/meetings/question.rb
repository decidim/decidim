# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Question in the Decidim::Meetings component.
    class Question < Meetings::ApplicationRecord
      include Decidim::TranslatableResource

      QUESTION_TYPES = %w(single_option multiple_option).freeze

      translatable_fields :body
      enum status: { unpublished: 0, published: 1, closed: 2 }

      belongs_to :questionnaire, class_name: "Decidim::Meetings::Questionnaire", foreign_key: "decidim_questionnaire_id"

      has_many :answers,
               class_name: "Decidim::Meetings::Answer",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :answer_options,
               class_name: "Decidim::Meetings::AnswerOption",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      validates :question_type, inclusion: { in: QUESTION_TYPES }

      scope :visible, -> { where(status: [:published, :closed]) }

      def multiple_choice?
        %w(single_option multiple_option).include?(question_type)
      end

      # Public: returns whether the questionnaire is answered by the user or not.
      def answered_by?(user)
        questionnaire.answers.where({ user:, question: self }).any? if questionnaire.questions.present? && user.present?
      end

      def number_of_options
        answer_options.size
      end

      def translated_body
        Decidim::Forms::QuestionPresenter.new(self).translated_body
      end

      def answers_count
        questionnaire.answers.where(question: self).count
      end
    end
  end
end
