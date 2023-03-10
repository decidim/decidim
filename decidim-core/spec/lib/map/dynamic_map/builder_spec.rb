# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe DynamicMap::Builder do
      include_context "with dynamic map builder"

      describe "#map_element" do
        it "returns the expected markup" do
          config = ERB::Util.html_escape(js_options.to_json)
          expect(subject.map_element(id: "map", class: "test-map")).to eq(
            %(<div data-decidim-map="#{config}" data-markers-data="[]" id="map" class="test-map"></div>)
          )
        end
      end

      describe "#append_assets" do
        it "returns the expected stylesheet and javascript assets" do
          expect(subject.send(:template)).to receive(:append_javascript_pack_tag).with("decidim_map_provider_default")
          expect(subject.send(:template)).to receive(:append_stylesheet_pack_tag).with("decidim_map")
          subject.append_assets
        end
      end
    end
  end
end
