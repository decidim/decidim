# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Here do
          include_context "with map utility" do
            subject { utility }
          end

          describe "#builder_class" do
            it "returns the Builder class under the given module" do
              expect(utility.builder_class).to be(
                Decidim::Map::Provider::Autocomplete::Here::Builder
              )
            end
          end

          describe "#builder_options" do
            let(:config) { { api_key: "key1234" } }

            it "returns the correct builder options" do
              expect(subject.builder_options).to eq(api_key: "key1234")
            end

            context "with extra configurations" do
              let(:config) do
                {
                  api_key: "key1234",
                  foo: "bar"
                }
              end

              it "returns the correct builder options" do
                expect(subject.builder_options).to eq(api_key: "key1234", foo: "bar")
              end
            end
          end
        end
      end
    end
  end
end
