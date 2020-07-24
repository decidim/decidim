# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Questionnaire in the Decidim::Forms component.
    class Questionnaire < Forms::ApplicationRecord
      include Decidim::Publicable

      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :answers, class_name: "Answer", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      # Public: returns whether the questionnaire questions can be modified or not.
      def questions_editable?
        has_component = questionnaire_for.respond_to? :component
        (has_component && !questionnaire_for.component.published?) || answers.empty?
      end

      # Public: returns whether the questionnaire is answered by the user or not.
      def answered_by?(user)
        query = user.is_a?(String) ? { session_token: user } : { user: user }
        answers.where(query).any? if questions.present?
      end
    end
  end
end
