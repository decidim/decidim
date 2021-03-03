# frozen_string_literal: true

module Decidim
  module Meetings
    # This class deals with uploading a main image to a Meeting.
    class MeetingImageUploader < RecordImageUploader
      process resize_to_limit: [1000, 1000]
    end
  end
end
