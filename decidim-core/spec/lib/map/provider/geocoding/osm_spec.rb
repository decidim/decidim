# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Geocoding
        describe Osm do
          include_context "with map utility" do
            subject { utility }
          end

          describe "#initialize" do
            let(:config) { { foo: "bar" } }

            it "configures Geocoder with the correct lookup configuration" do
              expected_config = {
                foo: "bar",
                http_headers: {
                  "User-Agent" => "Decidim/#{Decidim.version} (#{Decidim.application_name})",
                  "Referer" => organization.host
                }
              }

              expect(Geocoder).to receive(:configure).with(
                nominatim: expected_config
              )
              expect(subject).to be_a(described_class)
              expect(subject.configuration).to eq(expected_config)
            end
          end

          describe "#handle" do
            it "returns the correct handle" do
              expect(subject.handle).to eq(:nominatim)
            end
          end

          context "with geocoder request stubs" do
            let(:response) { File.read(Decidim::Dev.asset("geocoder_result_osm.json")) }

            before do
              stub_request(:get, request_url).with(
                headers: {
                  "User-Agent" => "Decidim/#{Decidim.version} (#{Decidim.application_name})",
                  "Referer" => organization.host
                }
              ).to_return(body: response)
            end

            describe "#coordinates" do
              let(:request_url) { "https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=#{CGI.escape(query)}" }
              let(:query) { "Madison Square Garden, 4 Penn Plaza, New York, NY" }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.coordinates(query)
                ).to eq([40.7504928941818, -73.993466492276])
              end
            end

            describe "#address" do
              let(:request_url) { "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=#{query[0]}&lon=#{query[1]}" }
              let(:query) { [40.7504928941818, -73.993466492276] }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.address(query)
                ).to eq("Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America")
              end
            end
          end
        end
      end
    end
  end
end
