# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MapHelper do
    describe "#static_map_link" do
      subject { helper.static_map_link(resource, options, map_html_options) }
      let(:resource) { create(:meeting) }
      let(:organization) { create(:organization) }
      let(:options) { {} }
      let(:map_html_options) { {} }

      before do
        allow(helper).to receive(:current_organization).and_return(organization)
      end

      it "returns the map" do
        expect(subject).to match(/^<a class="static-map".*/)
        expect(subject).to match(/img alt/)
      end

      context "when there is a map_html_options parameter defined" do
        let(:map_html_options) { { class: "another-static-map" } }

        it "returns the map with the new html options" do
          expect(subject).to match(/^<a class="another-static-map".*/)
          expect(subject).to match(/img alt/)
        end
      end
    end
  end
end
