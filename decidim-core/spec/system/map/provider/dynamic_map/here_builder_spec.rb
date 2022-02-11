# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module DynamicMap
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
                window.addEventListener("DOMContentLoaded", () => {
                  window.mapIndex = 1;
                  L.tileLayer.here = function(config) {
                    var configId = "tile_layer_config" + window.mapIndex;

                    $("#content").append('<div id="' + configId + '"></div>');
                    $("#" + configId).text(JSON.stringify(config));

                    window.mapIndex++;

                    var mockLayer = { addTo: function(target) {} };
                    return mockLayer;
                  };
                });
                </script>
              HEAD
            end

            it "sets up the tile layer", :slow do
              expect(page).to have_selector(
                "#tile_layer_config1",
                text: options[:tile_layer][:options].to_json
              )
            end
          end
        end
      end
    end
  end
end
