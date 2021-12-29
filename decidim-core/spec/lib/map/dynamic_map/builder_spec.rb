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
          expect(subject.stylesheet_snippets).to match(
            %r{<link rel="stylesheet" media="screen" href="/packs-test/css/decidim_map(-[^.]*)?\.css" />}
          )
        end
      end

      describe "#javascript_snippets" do
        it "returns the expected JavaScript assets" do
          expect(subject.javascript_snippets).to match(
            %r{<script src="/packs-test/js/decidim_map_provider_default(-[^.]*)?\.js"></script>}
          )
        end
      end
    end
  end
end
