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

          include_context "with map utility" do
            subject { utility }

            let(:config) { { api_key: } }
          end

          describe "#url_params" do
            it "returns the default params" do
              expect(
                subject.url_params(
                  latitude:,
                  longitude:
                )
              ).to eq(
                apiKey: "key1234",
                c: "#{latitude}, #{longitude}",
                z: 15,
                w: 120,
                h: 120,
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
              let(:api_key) { %w(appid123 secret456) }

              it "returns the default params" do
                expect(
                  subject.url_params(
                    latitude:,
                    longitude:
                  )
                ).to eq(
                  app_id: "appid123",
                  app_code: "secret456",
                  c: "#{latitude}, #{longitude}",
                  z: 15,
                  w: 120,
                  h: 120,
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
