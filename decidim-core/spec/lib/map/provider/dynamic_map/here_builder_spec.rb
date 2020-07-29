# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module DynamicMap
        describe Here::Builder do
          include_context "with dynamic map builder" do
            let(:options) do
              {
                tile_layer: {
                  options: {
                    apiKey: "key1234"
                  }
                }
              }
            end
          end

          describe "#map_element" do
            it "returns the expected markup" do
              config = ERB::Util.html_escape(js_options.to_json)
              expect(subject.map_element(id: "map", class: "test-map")).to eq(
                %(<div data-decidim-map="#{config}" data-markers-data="[]" id="map" class="test-map"></div>)
              )
            end
          end

          describe "#javascript_snippets" do
            it "returns the expected JavaScript assets" do
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/leaflet\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/leaflet-tilelayer-here\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/leaflet-svg-icon\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/leaflet\.markercluster\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/jquery-tmpl\.self-[^\.]*\.js\?body=1"></script>}
              )
              expect(subject.javascript_snippets).to match(
                %r{<script src="/assets/decidim/map\.self-[^\.]*\.js\?body=1"></script>}
              )
            end
          end
        end

        # UI tests for the builder
        describe Here::Builder, type: :system do
          it_behaves_like "a page with dynamic map" do
            let(:options) do
              {
                tile_layer: {
                  options: {
                    apiKey: "key1234"
                  }
                }
              }
            end
            let(:html_head) do
              # Overrides Leaflet's `L.tileLayer.here` method which should be
              # called by the builder. This writes its results to the view for
              # further inspection in the rspec expectations.
              <<~HEAD
                <script type="text/javascript">
                  L.tileLayer.here = function(config) {
                    $("body").append('<div id="tile_layer_config"></div>');
                    $("#tile_layer_config").text(JSON.stringify(config));

                    var mockLayer = { addTo: function(target) {} };
                    return mockLayer;
                  };
                </script>
              HEAD
            end

            it "sets up the tile layer" do
              expect(page).to have_selector(
                "#tile_layer_config",
                text: options[:tile_layer][:options].to_json
              )
            end
          end
        end
      end
    end
  end
end
