# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Questionnaire in the Decidim::Meetings component.
    class Questionnaire < Meetings::ApplicationRecord
      include Decidim::Traceable

      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :answers, class_name: "Answer", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      # Public: returns whether the questionnaire questions can be modified or not.
      def questions_editable?
        has_component = questionnaire_for.meeting.respond_to? :component
        (has_component && !questionnaire_for.meeting.component.published?) || answers.empty?
      end

      def all_questions_unpublished?
        questions.all?(&:unpublished?)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::QuestionnairePresenter
      end
    end
  end
end
