# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the URL address of an online meeting.
    class MeetingUrlCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include LayoutHelper

      private

      def resource_icon
        icon "video", class: "icon--big", role: "img", "aria-hidden": true
      end
    end
  end
end
