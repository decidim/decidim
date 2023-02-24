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

      describe "#stylesheet_snippets" do
        it "returns the expected stylesheet assets" do
          expect(subject.send(:template)).to receive(:append_stylesheet_pack_tag).with("decidim_map")
          subject.stylesheet_snippets
        end
      end

      describe "#javascript_snippets" do
        it "returns the expected JavaScript assets" do
          expect(subject.send(:template)).to receive(:append_javascript_pack_tag).with("decidim_map_provider_default")
          subject.javascript_snippets
        end
      end
    end
  end
end
