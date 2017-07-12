# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingsHelper do
      describe "meeting_description" do
        it "truncates meeting description respecting the html tags" do
          meeting = create(:meeting, description: { "en" => "<p>This is a long description with some <b>bold text</b></p>" })
          expect(helper.meeting_description(meeting, 40)).to match("<p>This is a long description with some <b>bol</b>...")
        end
      end
    end
  end
end
