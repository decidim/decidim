# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class UpcomingMeetingsCell < Decidim::ViewModel
        include Decidim::CardHelper

        def show
          return if upcoming_meetings.blank?

          render
        end

        def upcoming_meetings
          @upcoming_meetings ||= Decidim::Meetings::Meeting
                                 .includes(:author, component: :participatory_space)
                                 .where(component: meeting_components)
                                 .visible_for(current_user)
                                 .published
                                 .where("end_time >= ?", Time.current)
                                 .except_withdrawn
                                 .not_hidden
                                 .order(start_time: :asc)
                                 .limit(limit)
        end

        def geolocation_enabled?
          Decidim::Map.available?(:geocoding)
        end

        def meetings_directory_path
          Decidim::Meetings::DirectoryEngine.routes.url_helpers.root_path
        end

        private

        def limit
          geolocation_enabled? ? 4 : 8
        end

        def meeting_components
          @meeting_components ||= Decidim::Component
                                  .where(manifest_name: "meetings")
                                  .where(participatory_space: participatory_spaces)
                                  .published
        end

        def participatory_spaces
          @participatory_spaces ||= current_organization.public_participatory_spaces
        end
      end
    end
  end
end
