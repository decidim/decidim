# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingsHelper do
      describe "#meeting_description" do
        it "truncates meeting description respecting the html tags" do
          meeting = create(:meeting, description: { "en" => "<p>This is a long description with some <b>bold text</b></p>" })
          expect(helper.meeting_description(meeting, 40)).to match("<p>This is a long description with some <b>bol</b>...")
        end
      end

      describe "#google_calendar_event_url" do
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

      describe "#render_schema_org_event_meeting" do
        subject { helper.render_schema_org_event_meeting(meeting) }

        let!(:meeting) { create(:meeting, :published, latitude:, longitude:) }
        let(:latitude) { 40.7504928941818 }
        let(:longitude) { -73.993466492276 }

        let(:geocoder_request_url) { "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=#{latitude}&lon=#{longitude}" }
        let(:geocoder_query) { "Madison Square Garden, 4 Penn Plaza, New York, NY" }
        let(:geocoder_response) { File.read(Decidim::Dev.asset("geocoder_result_osm.json")) }

        before do
          stub_request(:get, geocoder_request_url).with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby"
            }
          ).to_return(body: geocoder_response)
        end

        it "renders a schema.org event" do
          keys = JSON.parse(subject).keys
          expect(keys).to include("@context")
          expect(keys).to include("@type")
          expect(keys).to include("name")
          expect(keys).to include("description")
          expect(keys).to include("startDate")
          expect(keys).to include("endDate")
          expect(keys).to include("organizer")
          expect(keys).to include("eventAttendanceMode")
          expect(keys).to include("eventStatus")
          expect(keys).to include("location")
        end
      end
    end
  end
end
