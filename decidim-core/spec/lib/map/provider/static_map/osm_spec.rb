# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module StaticMap
        describe Osm do
          let(:latitude) { 60.149790 }
          let(:longitude) { 24.887430 }

          include_context "with map utility" do
            subject { utility }
          end

          describe "#url_params" do
            it "returns the default params" do
              expect(
                subject.url_params(
                  latitude:,
                  longitude:
                )
              ).to eq(
                geojson: {
                  type: "Point",
                  coordinates: [longitude, latitude]
                }.to_json,
                zoom: 15,
                width: 120,
                height: 120
              )
            end

            context "with custom options" do
              it "returns the correct params" do
                expect(
                  subject.url_params(
                    latitude:,
                    longitude:,
                    options: {
                      zoom: 10,
                      width: 200,
                      height: 200,
                      foo: "bar"
                    }
                  )
                ).to eq(
                  geojson: {
                    type: "Point",
                    coordinates: [longitude, latitude]
                  }.to_json,
                  zoom: 10,
                  width: 200,
                  height: 200
                )
              end
            end
          end
        end
      end
    end
  end
end
