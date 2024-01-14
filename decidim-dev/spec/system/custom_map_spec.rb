# frozen_string_literal: true

require "spec_helper"

describe "Custom map" do
  include_context "with frontend map builder" do
    let(:template_class) do
      Class.new(ActionView::Base) do
        include Decidim::MapHelper

        def protect_against_forgery?
          false
        end

        def snippets
          @snippets ||= Decidim::Snippets.new
        end
      end
    end
  end

  include_context "with frontend map elements" do
    let(:html_body) do
      Decidim.maps = map_config
      Decidim::Map.reset_utility_configuration!

      markers = marker_data
      template.instance_eval do
        dynamic_map_for type: "custom", markers:, popup_template_id: "custom-popup" do
          append_javascript_pack_tag("decidim_dev_test_custom_map")

          <<~HTML.html_safe
            <template id="custom-popup">
              <div>
                <h3>${title}</h3>
              </div>
            </template>
          HTML
        end
      end
    end
  end

  shared_examples "working custom map" do
    it "allows overriding the map controller" do
      expect(page).to have_content("Custom map started")
      expect(page).to have_content("Custom map ready")
    end

    it "shows the map marker" do
      within "[data-decidim-map]" do
        expect(page).to have_css(".leaflet-marker-icon", count: marker_data.length)
      end
    end
  end

  let(:marker_data) do
    [
      { title: "Test 1", latitude: 41.385063, longitude: 2.173404 }
    ]
  end

  context "with OSM" do
    let(:map_config) do
      {
        provider: :osm,
        dynamic: { tile_layer: { url: "/maptiles/{z}/{x}/{y}.png" } }
      }
    end

    it_behaves_like "working custom map"
  end

  context "with Here" do
    let(:map_config) do
      {
        provider: :here
      }
    end

    it_behaves_like "working custom map"
  end
end
