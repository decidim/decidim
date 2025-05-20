# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Questionnaire in the Decidim::Elections component.
    class Questionnaire < Elections::ApplicationRecord
      include Decidim::Traceable

      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      def self.log_presenter_class_for(_log)
        Decidim::Elections::AdminLog::QuestionnairePresenter
      end
    end
  end
end
