# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module DynamicMap
        describe Osm do
          include_context "with map utility" do
            subject { utility }
          end

          describe "#builder_class" do
            it "returns the Builder class under the given module" do
              expect(utility.builder_class).to be(
                Decidim::Map::DynamicMap::Builder
              )
            end
          end

          describe "#builder_options" do
            let(:config) do
              {
                tile_layer: {
                  url: "https://tiles.example.org"
                }
              }
            end

            it "prepares and returns the correct builder options" do
              expect(utility.builder_options).to eq(
                marker_color: "#ef604d",
                tile_layer: {
                  url: "https://tiles.example.org",
                  options: {}
                }
              )
            end

            context "when tile layer has extra configurations" do
              let(:config) do
                {
                  tile_layer: {
                    url: "https://tiles.example.org",
                    foo: "bar",
                    baz: "foobar"
                  }
                }
              end

              it "prepares and returns the correct builder options" do
                expect(utility.builder_options).to eq(
                  marker_color: "#ef604d",
                  tile_layer: {
                    url: "https://tiles.example.org",
                    options: { foo: "bar", baz: "foobar" }
                  }
                )
              end
            end

            context "when the api_key parameter is true" do
              let(:config) do
                {
                  api_key: "key1234",
                  tile_layer: {
                    url: "https://tiles.example.org",
                    api_key: true,
                    foo: "bar",
                    baz: "foobar"
                  }
                }
              end

              it "prepares and returns the correct builder options" do
                expect(utility.builder_options).to eq(
                  marker_color: "#ef604d",
                  tile_layer: {
                    url: "https://tiles.example.org",
                    options: { api_key: "key1234", foo: "bar", baz: "foobar" }
                  }
                )
              end
            end
          end
        end
      end
    end
  end
end
