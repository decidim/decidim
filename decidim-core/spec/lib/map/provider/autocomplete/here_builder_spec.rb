# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Here::Builder do
          include_context "with dynamic map builder" do
            let(:options) { { apiKey: "key1234" } }
          end

          describe "#append_assets" do
            it "returns the expected JavaScript assets" do
              expect(subject.send(:template)).to receive(:append_javascript_pack_tag).with("decidim_geocoding_provider_here")
              subject.append_assets
            end
          end
        end
      end
    end
  end
end
