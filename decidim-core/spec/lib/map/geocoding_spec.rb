# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Geocoding
        # A dummy geocoding provider to test the geocoding utility.
        class Test < ::Decidim::Map::Geocoding; end
      end
    end

    describe Geocoding do
      include_context "with map utility" do
        subject { utility }

        let(:utility_class) { Provider::Geocoding::Test }
      end

      describe "#initialize" do
        let(:config) { { foo: "bar" } }

        it "configures Geocoder with the correct lookup configuration" do
          expected_config = {
            foo: "bar",
            http_headers: { "Referer" => organization.host }
          }

          expect(Geocoder).to receive(:configure).with(
            test: expected_config
          )
          expect(subject).to be_a(described_class)
          expect(subject.configuration).to eq(expected_config)
        end
      end

      describe "#handle" do
        it "returns the correct dummy provider's handle" do
          expect(subject.handle).to eq(:test)
        end
      end

      describe "#search" do
        let(:query) { double }
        let(:options) { { foo: "bar" } }

        it "calls the Geocoder.search method with correct arguments" do
          expect(Geocoder).to receive(:search).with(
            query,
            { lookup: :test, language: "en" }.merge(options)
          )

          subject.search(query, options)
        end
      end

      describe "#coordinates" do
        let(:query) { double }
        let(:options) { { foo: "bar" } }

        it "calls the Geocoder.coordinates method with correct arguments" do
          expect(Geocoder).to receive(:coordinates).with(
            query,
            { lookup: :test, language: "en" }.merge(options)
          )

          subject.coordinates(query, options)
        end
      end

      describe "#address" do
        let(:query) { double }
        let(:options) { { foo: "bar" } }

        it "calls the Geocoder.search method with correct arguments" do
          allow(Geocoder).to receive(:search).with(
            query,
            { lookup: :test, language: "en" }.merge(options)
          ).and_return([])

          expect(Geocoder).to receive(:search).with(
            query,
            { lookup: :test, language: "en" }.merge(options)
          )

          subject.address(query, options)
        end
      end

      context "with geocoder stubs" do
        let(:geocoder_search) { "New York, NY" }
        let(:geocoder_results) do
          [
            {
              "coordinates" => [40.7143528, -74.0059731],
              "address" => "New York, NY, USA",
              "state" => "New York",
              "state_code" => "NY",
              "country" => "United States",
              "country_code" => "US"
            }
          ]
        end

        before do
          Geocoder::Lookup::Test.add_stub(geocoder_search, geocoder_results)
        end

        describe "#search" do
          it "returns the geocoder stubbed results" do
            results = subject.search(geocoder_search)
            expect(results.length).to be(geocoder_results.length)

            geocoder_results.each_with_index do |result_values, ind|
              result = results[ind]
              result_values.each do |key, value|
                expect(result.public_send(key)).to eq(value)
              end
            end
          end
        end

        describe "#coordinates" do
          it "returns the geocoder stubbed first result" do
            expect(
              subject.coordinates(geocoder_search)
            ).to eq([40.7143528, -74.0059731])
          end
        end

        describe "#address" do
          let(:geocoder_search) { [40.7143528, -74.0059731] }

          it "returns the geocoder stubbed first result" do
            expect(
              subject.address(geocoder_search)
            ).to eq("New York, NY, USA")
          end

          context "with multiple results" do
            let(:geocoder_search) { [40.7143528, -74.0059731] }
            let(:geocoder_results) do
              [
                {
                  "coordinates" => [60.169857, 24.938379],
                  "address" => "Helsinki, Finland",
                  "state" => "Uusimaa",
                  "state_code" => "",
                  "country" => "Finland",
                  "country_code" => "FI"
                },
                {
                  "coordinates" => [41.385063, 2.173404],
                  "address" => "Barcelona, Barcelona, Spain",
                  "state" => "Barcelona",
                  "state_code" => "",
                  "country" => "Spain",
                  "country_code" => "ES"
                },
                {
                  "coordinates" => [40.7143520, -74.0059732],
                  "address" => "Closest Result, New York, NY, USA",
                  "state" => "New York",
                  "state_code" => "NY",
                  "country" => "United States",
                  "country_code" => "US"
                },
                {
                  "coordinates" => [52.520008, 13.404954],
                  "address" => "Berlin, Berlin, Germany",
                  "state" => "Berlin",
                  "state_code" => "",
                  "country" => "Germany",
                  "country_code" => "DE"
                }
              ]
            end

            it "returns the closest result" do
              expect(
                subject.address(geocoder_search)
              ).to eq("Closest Result, New York, NY, USA")
            end
          end
        end
      end
    end
  end
end
