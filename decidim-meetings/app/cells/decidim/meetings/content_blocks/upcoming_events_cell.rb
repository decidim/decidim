# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class UpcomingEventsCell < Decidim::ViewModel
        include Decidim::CardHelper

        delegate :current_organization, to: :controller

        def show
          return if upcoming_events.blank?
        end

        def upcoming_events
          @upcoming_events ||= Decidim::Meetings::Meeting
                               .includes(component: :participatory_space)
                               .where(component: meeting_components)
                               .where("end_time >= ?", Time.current)
                               .order(start_time: :desc)
                               .limit(limit)
        end

        def geolocation_enabled?
          Decidim.geocoder.present?
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
