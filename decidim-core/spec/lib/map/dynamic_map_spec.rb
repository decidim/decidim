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
            { marker_color: "#e02d2d",
              tile_layer: { url: nil, options: {} },
              zoom_in_text: "Zoom in",
              zoom_out_text: "Zoom out" }
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
            marker_color: "#e02d2d",
            tile_layer: { url: nil, options: {} },
            zoom_in_text: "Zoom in",
            zoom_out_text: "Zoom out"
          )
        end
      end

      describe "Builder" do
        include_context "with dynamic map builder" do
          subject { utility.create_builder(template, options) }
        end

        describe "#view_options" do
          it "includes zoom control translations" do
            view_opts = subject.send(:view_options)
            expect(view_opts).to include("zoomInText" => "Zoom in", "zoomOutText" => "Zoom out")
          end
        end
      end
    end
  end
end
