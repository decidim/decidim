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
        let(:options) { {} }

        it "creates a new builder instance" do
          expect(Decidim::Map::DynamicMap::Builder).to receive(:new).with(
            template,
            { marker_color: "#ef604d",
              tile_layer: { url: nil, options: {} } }
          ).and_call_original

          builder = subject.create_builder(template, options)
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
            marker_color: "#ef604d",
            tile_layer: { url: nil, options: {} }
          )
        end
      end
    end
  end
end
