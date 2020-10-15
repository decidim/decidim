# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Osm do
          include_context "with map utility" do
            subject { utility }
          end

          describe "#builder_class" do
            it "returns the Builder class under the given module" do
              expect(utility.builder_class).to be(
                Decidim::Map::Provider::Autocomplete::Osm::Builder
              )
            end
          end

          describe "#builder_options" do
            let(:config) { { url: "https://photon.example.org/api/" } }

            it "prepares and returns the correct builder options" do
              expect(utility.builder_options).to eq(
                url: "https://photon.example.org/api/"
              )
            end

            context "when the config has extra configurations" do
              let(:config) do
                {
                  url: "https://photon.example.org/api/",
                  foo: "bar",
                  baz: "foobar"
                }
              end

              it "prepares and returns the correct builder options" do
                expect(utility.builder_options).to eq(
                  url: "https://photon.example.org/api/",
                  foo: "bar",
                  baz: "foobar"
                )
              end
            end
          end
        end
      end
    end
  end
end
