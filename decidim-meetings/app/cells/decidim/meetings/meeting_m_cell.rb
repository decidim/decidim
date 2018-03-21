# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Medium (:m) meeting card
    # for an given instance of a Meeting
    class MeetingMCell < Decidim::Meetings::MeetingCell
      def show
        render
      end

      def header
        render
      end
    end
  end
end
