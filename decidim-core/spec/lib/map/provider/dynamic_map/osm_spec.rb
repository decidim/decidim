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
                tile_layer: {
                  url: "https://tiles.example.org",
                  configuration: {}
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
                  tile_layer: {
                    url: "https://tiles.example.org",
                    configuration: { foo: "bar", baz: "foobar" }
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
