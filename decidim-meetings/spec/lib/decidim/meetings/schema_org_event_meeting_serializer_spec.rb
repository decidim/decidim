# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe SchemaOrgEventMeetingSerializer do
    subject do
      described_class.new(meeting)
    end

    let!(:meeting) { create(:meeting, :published, latitude:, longitude:) }
    let(:organization) { meeting.component.organization }

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

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the @context" do
        expect(serialized[:@context]).to eq("https://schema.org")
      end

      it "serializes the @type" do
        expect(serialized[:@type]).to eq("Event")
      end

      it "serializes the name" do
        expect(serialized).to include(name: decidim_escape_translated(meeting.title))
      end

      it "serializes the description" do
        expect(serialized).to include(description: decidim_escape_translated(meeting.description))
      end

      it "serializes the startDate" do
        expect(serialized).to include(startDate: meeting.start_time.iso8601)
      end

      it "serializes the endDate" do
        expect(serialized).to include(endDate: meeting.end_time.iso8601)
      end

      describe "authors" do
        context "with official author" do
          let!(:meeting) { create(:meeting, :official, :published, latitude:, longitude:) }

          it "serializes the organizer" do
            expect(serialized[:organizer][:@type]).to eq("Organization")
            expect(serialized[:organizer][:name]).to eq(translated_attribute(meeting.author.name))
            expect(serialized[:organizer][:url]).to eq("http://#{organization.host}:#{Capybara.server_port}/")
          end
        end

        context "with participant author" do
          let!(:meeting) { create(:meeting, :participant_author, :published, latitude:, longitude:) }

          it "serializes the organizer" do
            expect(serialized[:organizer][:@type]).to eq("Person")
            expect(serialized[:organizer][:name]).to eq(meeting.author.name)
            expect(serialized[:organizer][:url]).to eq("http://#{organization.host}:#{Capybara.server_port}/profiles/#{meeting.author.nickname}")
          end

          context "with deleted author" do
            let(:organization) { create(:organization) }
            let(:user) { create(:user, :deleted, organization:) }
            let(:component) { create(:meeting_component, :published, organization:) }
            let!(:meeting) { create(:meeting, :published, author: user.reload, component:, latitude:, longitude:) }

            it "serializes the organizer" do
              expect(serialized[:organizer][:@type]).to eq("Person")
              expect(serialized[:organizer][:name]).to eq(meeting.author.name)
              expect(serialized[:organizer][:url]).to eq("")
            end
          end
        end
      end

      describe "types of meetings" do
        context "with in-person meeting" do
          it "serializes the eventAttendanceMode" do
            expect(serialized).to include(eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode")
          end

          it "serializes the location" do
            expect(serialized[:location][:@type]).to eq("Place")
            expect(serialized[:location][:name]).to eq(decidim_escape_translated(meeting.location))
            expect(serialized[:location][:address][:@type]).to eq("PostalAddress")
            expect(serialized[:location][:address][:streetAddress]).to eq(translated_attribute(meeting.address))
            expect(serialized[:location][:address][:addressLocality]).to eq("New York City")
            expect(serialized[:location][:address][:addressRegion]).to eq("New York")
            expect(serialized[:location][:address][:postalCode]).to eq("10001")
            expect(serialized[:location][:address][:addressCountry]).to eq("United States of America")
          end

          context "when the geocoder does not work" do
            let(:geocoder_response) do
              [
                {
                  lat: "40.7504928941818",
                  lon: "-73.993466492276",
                  display_name: "Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America",
                  type: "stadium"
                }
              ]
            end

            it "returns the location without the address details" do
              expect(serialized[:location][:address][:@type]).to eq("PostalAddress")
              expect(serialized[:location][:address][:streetAddress]).to eq(decidim_escape_translated(meeting.address))
              expect(serialized[:location][:address].keys).to eq([:@type, :streetAddress])
            end
          end
        end

        context "with online meeting" do
          let(:meeting) { create(:meeting, :published, :online) }

          it "serializes the eventAttendanceMode" do
            expect(serialized).to include(eventAttendanceMode: "https://schema.org/OnlineEventAttendanceMode")
          end

          it "serializes the location" do
            expect(serialized[:location][:@type]).to eq("VirtualLocation")
            expect(serialized[:location][:url]).to eq(meeting.online_meeting_url)
          end
        end

        context "with hybrid meeting" do
          let(:meeting) { create(:meeting, :published, :hybrid, latitude:, longitude:) }

          it "serializes the eventAttendanceMode" do
            expect(serialized).to include(eventAttendanceMode: "https://schema.org/MixedEventAttendanceMode")
          end

          it "serializes both locations" do
            expect(serialized[:location].first[:@type]).to eq("Place")
            expect(serialized[:location].first[:name]).to eq(decidim_escape_translated(meeting.location))
            expect(serialized[:location].first[:address][:@type]).to eq("PostalAddress")
            expect(serialized[:location].first[:address][:streetAddress]).to eq(decidim_escape_translated(meeting.address))
            expect(serialized[:location].first[:address][:addressLocality]).to eq("New York City")
            expect(serialized[:location].first[:address][:addressRegion]).to eq("New York")
            expect(serialized[:location].first[:address][:postalCode]).to eq("10001")
            expect(serialized[:location].first[:address][:addressCountry]).to eq("United States of America")

            expect(serialized[:location].second[:@type]).to eq("VirtualLocation")
            expect(serialized[:location].second[:url]).to eq(meeting.online_meeting_url)
          end
        end
      end

      describe "images" do
        context "without images" do
          it "does not has the attribute" do
            expect(serialized).not_to include(:image)
          end
        end

        context "with one image" do
          let!(:attachment) { create(:attachment, :with_image, attached_to: meeting, file: attachment_file) }
          let!(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

          it "serializes the image" do
            expect(serialized[:image]).to include(attachment.thumbnail_url)
          end
        end

        context "with multiple images" do
          let!(:attachment1) { create(:attachment, :with_image, attached_to: meeting, file: attachment1_file) }
          let!(:attachment1_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
          let!(:attachment2) { create(:attachment, :with_image, attached_to: meeting, file: attachment2_file) }
          let!(:attachment2_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

          it "serializes the images" do
            expect(serialized[:image]).to include(attachment1.thumbnail_url)
            expect(serialized[:image]).to include(attachment2.thumbnail_url)
          end
        end
      end
    end
  end
end
