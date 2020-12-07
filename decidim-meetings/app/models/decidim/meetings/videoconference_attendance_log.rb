# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Videoconference Attendance Log in the Decidim::Meetings component.
    class VideoconferenceAttendanceLog < Meetings::ApplicationRecord
      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true

      validates :videoconference_user_id, :room_name, presence: true

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end
    end
  end
end
