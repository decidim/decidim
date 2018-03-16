# frozen_string_literal: true

module Decidim
  module Meetings
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
