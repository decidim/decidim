# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Questionnaire in the Decidim::Meetings component.
    class Questionnaire < Meetings::ApplicationRecord
      include Decidim::Traceable

      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :responses, class_name: "Response", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      def all_questions_unpublished?
        questions.all?(&:unpublished?)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::QuestionnairePresenter
      end
    end
  end
end
