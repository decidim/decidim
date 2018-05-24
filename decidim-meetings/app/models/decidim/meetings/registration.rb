# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Registration in the Decidim::Meetings component.
    class Registration < Meetings::ApplicationRecord
      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      # has_one :questionnaire, as: :questionnaire_for, class_name: "Decidim::Meetings::QuestionnaireAnswer"

      validates :user, uniqueness: { scope: :meeting }
    end
  end
end
