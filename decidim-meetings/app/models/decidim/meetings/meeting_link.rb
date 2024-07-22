# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingLink < Meetings::ApplicationRecord
      include Decidim::HasComponent

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      def self.find_meetings(component:)
        meetings = Meeting
                   .joins(:meeting_links)
                   .where("decidim_meetings_meeting_links.component": component)
                   .filter do |meeting|
          space = meeting.component.participatory_space

          next true unless space.private_space?

          if space.respond_to?(:is_transparent?)
            space.is_transparent?
          else
            false
          end
        end

        Meeting.where(id: meetings.map(&:id))
      end
    end
  end
end
