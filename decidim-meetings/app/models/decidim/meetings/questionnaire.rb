# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Questionnaire in the Decidim::Meetings component.
    class Questionnaire < Meetings::ApplicationRecord
      TYPES = %w(registration).freeze

      belongs_to :meeting

      has_many :questions, -> { order(:position) }, class_name: "QuestionnaireQuestion", foreign_key: "decidim_meetings_questionnaire_id", dependent: :destroy
      has_many :answers, class_name: "QuestionnaireAnswer", foreign_key: "decidim_meetings_questionnaire_id", dependent: :destroy

      # Public: returns whether the questionnaire questions can be modified or not.
      def questions_editable?
        answers.empty?
      end

      # Public: returns whether the questionnaire is answered by the user or not.
      def answered_by?(user)
        answers.where(user: user).count == questions.length
      end
    end
  end
end
