# frozen_string_literal: true
module Decidim
  module Surveys
    # The data store for a SurveyQuestion in the Decidim::Surveys component.
    class SurveyQuestion < Surveys::ApplicationRecord
      TYPES = %w(short_answer long_answer single_option multiple_option).freeze

      belongs_to :survey, class_name: Survey, foreign_key: "decidim_survey_id"

      # Rectify can't handle a hash when using the from_model method so
      # the answer options must be converted to struct.
      def answer_options
        self[:answer_options].map { |option| OpenStruct.new(option) }
      end
    end
  end
end
