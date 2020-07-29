# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module DynamicMap
        describe Here do
          include_context "with map utility" do
            subject { utility }
          end

          describe "#builder_class" do
            it "returns the Builder class under the given module" do
              expect(utility.builder_class).to be(
                Decidim::Map::Provider::DynamicMap::Here::Builder
              )
            end
          end

          describe "#builder_options" do
            let(:config) do
              {
                api_key: "key1234",
                tile_layer: { foo: "bar" }
              }
            end

            it "returns the correct builder options" do
              expect(subject.builder_options).to eq(
                marker_color: "#ef604d",
                tile_layer: {
                  api_key: "key1234", foo: "bar"
                }
              )
            end

            context "with legacy style API key configuration" do
              let(:config) do
                {
                  api_key: %w(appid123 secret456),
                  tile_layer: { foo: "bar" }
                }
              end

              it "returns the correct builder options" do
                expect(ActiveSupport::Deprecation).to receive(:warn)
                expect(subject.builder_options).to eq(
                  marker_color: "#ef604d",
                  tile_layer: {
                    app_id: "appid123",
                    app_code: "secret456",
                    foo: "bar"
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
