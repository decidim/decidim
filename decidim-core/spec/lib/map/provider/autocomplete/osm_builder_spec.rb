# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Osm::Builder do
          include_context "with dynamic map builder" do
            let(:options) { { url: "https://photon.example.org/api/" } }
          end

          describe "#append_assets" do
            it "returns the expected JavaScript assets" do
              expect(subject.send(:template)).to receive(:append_javascript_pack_tag).with("decidim_geocoding_provider_photon")
              subject.append_assets
            end
          end
        end
      end
    end
  end
end
