# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module StaticMap
        describe Here do
          let(:latitude) { 60.149790 }
          let(:longitude) { 24.887430 }
          let(:api_key) { "key1234" }
          let(:url) { "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" }

          include_context "with map utility" do
            subject { utility }

            let(:config) { { api_key:, url: } }
          end

          describe "#url" do
            it "returns the URL in correct format" do
              size = Decidim::Map::StaticMap::DEFAULT_SIZE
              params = {
                apiKey: api_key,
                overlay: "point:#{latitude},#{longitude};icon=cp;size=large|#{latitude},#{longitude};style=circle;width=50m;color=%231B9D2C60"
              }
              expect(subject.url(latitude:, longitude:)).to eq(
                "#{url}:radius=90/#{size}x#{size}/png8?#{URI.encode_www_form(params)}"
              )
            end

            context "with legacy URL" do
              let(:url) { "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }

              it "returns the legacy style URL" do
                allow(ActiveSupport::Deprecation).to receive(:warn)

                params = {
                  c: "#{latitude}, #{longitude}",
                  z: Decidim::Map::StaticMap::DEFAULT_ZOOM,
                  w: Decidim::Map::StaticMap::DEFAULT_SIZE,
                  h: Decidim::Map::StaticMap::DEFAULT_SIZE,
                  f: 1,
                  apiKey: api_key
                }
                expect(subject.url(latitude:, longitude:)).to eq(
                  "#{url}?#{URI.encode_www_form(params)}"
                )
              end
            end
          end

          describe "#url_params" do
            before do
              allow(ActiveSupport::Deprecation).to receive(:warn)
            end

            it "returns the default params" do
              expect(
                subject.url_params(
                  latitude:,
                  longitude:
                )
              ).to eq(
                apiKey: "key1234",
                c: "#{latitude}, #{longitude}",
                z: Decidim::Map::StaticMap::DEFAULT_ZOOM,
                w: Decidim::Map::StaticMap::DEFAULT_SIZE,
                h: Decidim::Map::StaticMap::DEFAULT_SIZE,
                f: 1
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
                  apiKey: "key1234",
                  c: "#{latitude}, #{longitude}",
                  z: 10,
                  w: 200,
                  h: 200,
                  f: 1
                )
              end
            end

            context "with legacy style API key configuration" do
              let(:api_key) { "appid123secret456" }

              it "returns the default params" do
                expect(
                  subject.url_params(
                    latitude:,
                    longitude:
                  )
                ).to eq(
                  apiKey: "appid123secret456",
                  c: "#{latitude}, #{longitude}",
                  z: Decidim::Map::StaticMap::DEFAULT_ZOOM,
                  w: Decidim::Map::StaticMap::DEFAULT_SIZE,
                  h: Decidim::Map::StaticMap::DEFAULT_SIZE,
                  f: 1
                )
              end
            end
          end
        end
      end
    end
  end
end
