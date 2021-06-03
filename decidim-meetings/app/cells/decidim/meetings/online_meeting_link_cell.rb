# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the online meeting link section
    # of a online or both type of meeting.
    class OnlineMeetingLinkCell < Decidim::ViewModel
      include Decidim::LayoutHelper

      def show
        render
      end

      delegate :live?, to: :model

      private

      def live_event_url
        if model.show_iframe?
          Decidim::EngineRouter.main_proxy(model.component).meeting_live_event_path(meeting_id: model.id)
        else
          model.online_meeting_url
        end
      end
    end
  end
end
