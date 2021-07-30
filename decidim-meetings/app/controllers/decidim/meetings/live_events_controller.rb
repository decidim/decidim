# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the live event of the meeting
    class LiveEventsController < Decidim::Meetings::ApplicationController
      layout "decidim/meetings/layouts/live_event"

      include Decidim::Meetings::PollsResources

      helper_method :live_meeting_embed_code

      def show
        raise ActionController::RoutingError, "Not Found" unless meeting

        return if meeting.current_user_can_visit_meeting?(current_user)

        flash[:alert] = I18n.t("meeting.not_allowed", scope: "decidim.meetings")
        redirect_to(ResourceLocatorPresenter.new(meeting).index)
      end

      private

      def live_meeting_embed_code
        MeetingIframeEmbedder.new(meeting.online_meeting_url).embed_code(request.host)
      end
    end
  end
end
