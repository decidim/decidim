# frozen_string_literal: true

module Decidim
  module Meetings
    module Directory
      # Exposes the meeting resource so users can view them
      class MeetingsController < Decidim::Meetings::Directory::ApplicationController
        layout "layouts/decidim/application"

        include FilterResource
        include Paginable

        helper Decidim::FiltersHelper
        helper Decidim::ResourceHelper
        helper Decidim::ShortLinkHelper

        helper_method :meetings, :search

        def calendar
          render plain: CalendarRenderer.for(current_organization, filter_params), content_type: "type/calendar"
        end

        private

        def meetings
          is_past_meetings = params.dig("filter", "with_any_date")&.include?("past")
          @meetings ||= paginate(search.result.order(start_time: is_past_meetings ? :desc : :asc))
        end

        def search_collection
          Meeting.where(component: meeting_components).published.not_hidden.visible_for(current_user).with_availability(
            filter_params[:availability]
          ).includes(
            :component,
            attachments: :file_attachment
          )
        end

        def default_filter_params
          {
            with_any_date: "upcoming",
            title_or_description_cont: "",
            activity: "all",
            with_any_taxonomies: nil,
            with_any_space: nil,
            with_any_type: nil,
            with_any_origin: nil
          }
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
