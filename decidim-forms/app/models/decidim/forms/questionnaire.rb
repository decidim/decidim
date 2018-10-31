# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Questionnaire in the Decidim::Forms component.
    class Questionnaire < Forms::ApplicationRecord
      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :answers, class_name: "Answer", foreign_key: "decidim_questionnaire_id", dependent: :destroy

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
