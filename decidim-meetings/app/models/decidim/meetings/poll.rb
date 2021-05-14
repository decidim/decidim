# frozen_string_literal: true

module Decidim
  module Meetings
    class Poll < Meetings::ApplicationRecord
      include Decidim::Forms::HasQuestionnaire

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"

      delegate :organization, to: :meeting

      QUESTION_TYPES = %w(single_option multiple_option).freeze
    end
  end
end
