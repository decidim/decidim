# frozen_string_literal: true

module Decidim
  module Meetings
    class Poll < Meetings::ApplicationRecord
      has_one :questionnaire,
              class_name: "Decidim::Meetings::Questionnaire",
              dependent: :destroy,
              inverse_of: :questionnaire_for,
              as: :questionnaire_for

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"

      delegate :organization, to: :meeting

      QUESTION_TYPES = %w(single_option multiple_option).freeze
    end
  end
end
