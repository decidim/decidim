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

      describe "google_calendar_event_url" do
        it "generates a valid url containing title and start and end time" do
          meeting = create(:meeting, title: { "en" => "My title" }, start_time: "2001-01-01T01:01", end_time: "2002-02-02T02:02")
          uri = URI.parse(helper.google_calendar_event_url(meeting))

          expect(uri.host).to eq("calendar.google.com")
          params = CGI.parse(uri.query)

          expect(params["dates"].join).to include("20010101T0101")
          expect(params["dates"].join).to include("20020202T0202")
          expect(params["text"].join).to eq("My title")
        end
      end
    end
  end
end
