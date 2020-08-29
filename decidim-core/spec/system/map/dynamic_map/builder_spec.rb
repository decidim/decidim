# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe DynamicMap::Builder, type: :system do
      it_behaves_like "a page with dynamic map" do
        let(:html_head) do
          # Overrides Leaflet's `L.tileLayer` method which should be called by
          # the builder. This writes its results to the view for further
          # inspection in the rspec expectations.
          <<~HEAD
            <script type="text/javascript">
              L.tileLayer = function(url, config) {
                $("body").append('<div id="tile_layer_url"></div>');
                $("body").append('<div id="tile_layer_config"></div>');
                $("#tile_layer_url").text(url);
                $("#tile_layer_config").text(JSON.stringify(config));

                var mockLayer = { addTo: function(target) {} };
                return mockLayer;
              };
            </script>
          HEAD
        end

        it "sets up the tile layer" do
          expect(page).to have_selector(
            "#tile_layer_url",
            text: options[:tile_layer][:url]
          )
          expect(page).to have_selector(
            "#tile_layer_config",
            text: options[:tile_layer][:options].to_json
          )
        end
      end
    end
  end
end
