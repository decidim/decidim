# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticMapGenerator do
    subject { described_class.new(dummy_resource, options) }

    let(:dummy_resource) { create(:dummy_resource) }
    let(:options) do
      {
        zoom: 10,
        width: 200,
        height: 200
      }
    end
    let(:body) { "1234" }

    before do
      stub_request(:get, Regexp.new(Decidim.geocoder.fetch(:static_map_url))).to_return(body: body)
    end

    describe "#data" do
      it "returns the request body" do
        expect(subject.data).to eq(body)
      end

      context "when no resource is given" do
        let(:dummy_resource) { nil }

        it "returns nil" do
          expect(subject.data).to be_nil
        end
      end

      context "when no geocoder is configured" do
        before do
          allow(Decidim).to receive(:geocoder).and_return(nil)
        end

        it "returns nil" do
          expect(subject.data).to be_nil
        end
      end
    end
  end
end
