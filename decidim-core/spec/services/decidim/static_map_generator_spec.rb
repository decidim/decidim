# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticMapGenerator do
    let(:dummy_resource) { create(:dummy_resource) }
    let(:options) do
      {
        zoom: 10,
        width: 200,
        height: 200
      }
    end
    let(:body) { "1234" }
    subject { described_class.new(dummy_resource, options) }

    before do
      stub_request(:get, Regexp.new(Decidim.geocoder.fetch(:static_map_url))).to_return(body: body)
    end

    describe "#data" do
      it "returns the request body" do
        expect(subject.data).to eq(body)
      end
    end
  end
end
