# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe DynamicMap do
      include_context "with map utility" do
        subject { utility }
      end

      describe "#create_builder" do
        let(:template) { double }
        let(:map_id) { "map" }
        let(:options) { {} }

        it "creates a new builder instance" do
          expect(Decidim::Map::DynamicMap::Builder).to receive(:new).with(
            template,
            map_id,
            tile_layer: { url: nil, configuration: {} }
          ).and_call_original

          builder = subject.create_builder(template, map_id, options)
          expect(builder).to be_a(Decidim::Map::DynamicMap::Builder)
        end
      end

      describe "#builder_class" do
        it "returns the Builder class under the given module" do
          expect(utility.builder_class).to be(Decidim::Map::DynamicMap::Builder)
        end
      end

      describe "#builder_options" do
        it "prepares and returns the correct builder options" do
          expect(utility.builder_options).to eq(
            tile_layer: { url: nil, configuration: {} }
          )
        end
      end
    end
  end
end
