# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingMCell < Decidim::Meetings::MeetingCell
      # This cell renders the Medium (:m) meeting card
      # for an given instance of a Meeting
      def show
        render
      end

      def header
        render
      end
    end
  end
end
