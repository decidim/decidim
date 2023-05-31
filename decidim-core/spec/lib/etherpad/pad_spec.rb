# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Etherpad
    describe Pad do
      subject { described_class.new(pad_id) }

      let(:pad_id) { "Ret.-MEET-2021-11-1-3ff3aca8073fd33735cb8f92243464" }
      let(:etherpad_config) do
        {
          server:,
          api_key:
        }
      end
      let(:server) { "http://pad.example.org" }
      let(:api_key) { "API_KEY" }
      let(:api_version) { "1.2.1" }

      before do
        allow(Decidim).to receive(:etherpad).and_return(etherpad_config)
      end

      context "with etherpad request stubs" do
        before do
          %w(getReadOnlyID getText).each do |method|
            stub_request(
              :get,
              "#{server}/api/#{api_version}/#{method}?apikey=#{api_key}&padID=#{pad_id}"
            ).to_return(body: response)
          end
        end

        describe "#read_only_id" do
          let(:read_only_id) { "r.65d8cb7ca004c9a04afe3d0539935793" }
          let(:response) { %({"code":0,"message":"ok","data":{"readOnlyID":"#{read_only_id}"}}) }

          it "returns read only id" do
            expect(subject.read_only_id).to eq(read_only_id)
          end
        end

        describe "#text" do
          let(:text) { ::Faker::Lorem.paragraph }
          let(:response) { %({"code":0,"message":"ok","data":{"text":"#{text}"}}) }

          it "returns text of the pad" do
            expect(subject.text).to eq(text)
          end
        end
      end
    end
  end
end
