# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingLink < Meetings::ApplicationRecord
      include Decidim::HasComponent

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      # Finds all the meetings linked to the given component
      # filtering out meetings that belong to private not transparent spaces.
      def self.find_meetings(component:)
        meetings = Meeting
                   .joins(:meeting_links)
                   .where("decidim_meetings_meeting_links.component": component)
                   .filter do |meeting|
          !meeting.component.private_non_transparent_space?
        end

        Meeting.where(id: meetings.map(&:id))
      end
    end
  end
end
