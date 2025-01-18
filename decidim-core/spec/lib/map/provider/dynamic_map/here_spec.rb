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
                marker_color: "#e02d2d",
                tile_layer: {
                  api_key: "key1234", foo: "bar", language: "eng"
                }
              )
            end

            context "with different locale configuration" do
              before do
                allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
              end

              after do
                I18n.locale = "en"
              end

              it "returns the correct builder options for CA" do
                I18n.locale = "ca"
                expect(subject.builder_options).to eq(
                  marker_color: "#e02d2d",
                  tile_layer: {
                    api_key: "key1234", foo: "bar", language: "cat"
                  }
                )
              end

              it "returns the correct builder options for ES" do
                I18n.locale = "es"
                expect(subject.builder_options).to eq(
                  marker_color: "#e02d2d",
                  tile_layer: {
                    api_key: "key1234", foo: "bar", language: "spa"
                  }
                )
              end
            end

            context "with legacy style API key configuration" do
              let(:config) do
                {
                  api_key: %w(appid123 secret456),
                  tile_layer: { foo: "bar" }
                }
              end

              it "returns the correct builder options" do
                mock_object = instance_double(ActiveSupport::Deprecation)
                allow(Decidim).to receive(:deprecator).and_return(mock_object) # always return this mock instance when constructor is invoked
                expect(mock_object).to receive(:warn)

                # expect_any_instance_of(ActiveSupport::Deprecation).to receive(:warn)
                expect(subject.builder_options).to eq(
                  marker_color: "#e02d2d",
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
