# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Geocoding
        describe Here do
          include_context "with map utility" do
            subject { utility }

            let(:config) { { api_key: "key1234" } }
          end

          describe "#handle" do
            it "returns the correct handle" do
              expect(subject.handle).to eq(:here)
            end
          end

          context "with geocoder request stubs" do
            let(:response) { File.read(Decidim::Dev.asset("geocoder_result_here.json")) }

            before do
              stub_request(:get, request_url).with(
                headers: { "Referer" => organization.host }
              ).to_return(body: response)
            end

            describe "#coordinates" do
              let(:request_url) { "https://geocoder.ls.hereapi.com/6.2/geocode.json?apikey=key1234&gen=9&language=en&searchtext=#{CGI.escape(query)}" }
              let(:query) { "Madison Square Garden, 4 Penn Plaza, New York, NY" }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.coordinates(query)
                ).to eq([40.7504692, -73.9933777])
              end
            end

            describe "#address" do
              let(:request_url) { "https://reverse.geocoder.ls.hereapi.com/6.2/reversegeocode.json?apikey=key1234&gen=9&language=en&maxresults=5&mode=retrieveAddresses&prox=#{query[0]},#{query[1]},50&sortby=distance" }
              let(:query) { [40.7504692, -73.9933777] }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.address(query)
                ).to eq("4 Penn Plz, New York, NY 10001, United States")
              end
            end
          end
        end
      end
    end
  end
end
