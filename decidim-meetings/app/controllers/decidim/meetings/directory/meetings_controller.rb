# frozen_string_literal: true

module Decidim
  module Meetings
    module Directory
      # Exposes the meeting resource so users can view them
      class MeetingsController < Decidim::ApplicationController
        layout "layouts/decidim/application"

        include FilterResource
        include Paginable

        helper Decidim::WidgetUrlsHelper
        helper Decidim::FiltersHelper

        helper_method :meetings, :search

        def index
          @meeting_spaces = search.results.map do |meeting|
            klass = meeting.component.participatory_space.class
            [klass.model_name.name.underscore, klass.model_name.human]
          end.uniq
          @meeting_spaces << ["all", "All translated"]
        end

        private

        def meetings
          @meetings ||= paginate(search.results)
        end

        def search_klass
          MeetingSearch
        end

        def default_filter_params
          {
            date: "upcoming",
            search_text: "",
            scope_id: "",
            space: "all"
          }
        end

        def default_search_params
          {
            scope: Meeting.visible_meeting_for(current_user)
          }
        end

        def context_params
          { component: meeting_components, organization: current_organization }
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
