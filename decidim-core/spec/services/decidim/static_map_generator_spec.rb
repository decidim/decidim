# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticMapGenerator, configures_map: true do
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
      stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body:)
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

      context "when the static map service is disabled" do
        before do
          Decidim.maps = {
            provider: :test,
            static: false
          }
        end

        it "returns nil" do
          expect(subject.data).to be_nil
        end
      end
    end
  end
end
