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
              let(:request_url) { "https://geocode.search.hereapi.com/v1/geocode?apiKey=key1234&lang=en&q=5%20Rue%20Daunou,%2075000%20Paris,%20France" }
              let(:query) { "5 Rue Daunou, 75000 Paris, France" }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.coordinates(query)
                ).to eq([48.86926, 2.3321])
              end
            end

            describe "#address" do
              let(:request_url) { "https://revgeocode.search.hereapi.com/v1/revgeocode?apiKey=key1234&at=48.86926,2.3321,50&lang=en&maxresults=5&sortby=distance" }
              let(:query) { [48.86926, 2.3321] }

              it "requests the nominatim API with correct parameters" do
                expect(
                  subject.address(query)
                ).to eq("5 Rue Daunou, 75002 Paris, France")
              end
            end
          end
        end
      end
    end
  end
end
