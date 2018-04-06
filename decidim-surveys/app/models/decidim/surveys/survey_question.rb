# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a SurveyQuestion in the Decidim::Surveys component.
    class SurveyQuestion < Surveys::ApplicationRecord
      TYPES = %w(short_answer long_answer single_option multiple_option).freeze

      belongs_to :survey, class_name: "Survey", foreign_key: "decidim_survey_id"

      validates :question_type, inclusion: { in: TYPES }

      def multiple_choice?
        %w(single_option multiple_option).include?(question_type)
      end

      def mandatory_body?
        mandatory? && !multiple_choice?
      end

      def mandatory_choices?
        mandatory? && multiple_choice?
      end
    end
  end
end
