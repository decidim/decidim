# frozen_string_literal: true

module Decidim
  module Meetings
    class DownloadYourDataMeetingSerializer < Decidim::Meetings::MeetingSerializer
      # Serializes a Meeting for download your data feature
      #
      # Remove the author information as it is the same of the user that
      # requested the data
      def serialize
        super.except!(:author)
      end
    end
  end
end
