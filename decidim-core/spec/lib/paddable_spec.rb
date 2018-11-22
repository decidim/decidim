# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Paddable do
    let(:paddable) do
      build(:dummy_resource)
    end
    let(:etherpad_config) do
      {
        server: "http://pad.example.org",
        api_key: "API_KEY"
      }
    end
    let(:pad) { instance_double(EtherpadLite::Pad, id: "pad-id", read_only_id: "read-only-id") }

    before do
      allow(Decidim).to receive(:etherpad).and_return(etherpad_config)
      allow(paddable).to receive(:pad_id).and_return("secret-id")
      paddable.component.settings = { enable_pads_creation: true }
    end

    describe "pad_public_url" do
      before do
        allow(paddable).to receive(:pad).and_return(pad)
      end

      context "when there's no pad" do
        let(:pad) { nil }

        it "returns nil" do
          expect(paddable.pad_public_url).to be_nil
        end
      end

      it "returns the writable url" do
        expect(paddable.pad_public_url).to eq("http://pad.example.org/p/pad-id")
      end
    end

    describe "pad_read_only_url" do
      before do
        allow(paddable).to receive(:pad).and_return(pad)
      end

      context "when there's no pad" do
        let(:pad) { nil }

        it "returns nil" do
          expect(paddable.pad_read_only_url).to be_nil
        end
      end

      it "returns the read only url" do
        expect(paddable.pad_read_only_url).to eq("http://pad.example.org/p/read-only-id")
      end
    end

    describe "pad" do
      context "when there's no Etherpad service configured" do
        let(:etherpad_config) { nil }

        it "returns nil" do
          expect(paddable.pad).to be_nil
        end
      end

      context "when the component hasn't enabled pads" do
        before do
          paddable.component.settings = { enable_pads_creation: false }
        end

        it "returns nil" do
          expect(paddable.pad).to be_nil
        end
      end

      it "finds a pad in the server" do
        etherpad_service = instance_double(EtherpadLite::Instance)
        expect(paddable).to receive(:etherpad).and_return(etherpad_service)
        expect(etherpad_service).to receive(:pad).with("secret-id").and_return(pad)

        expect(paddable.pad).to eq(pad)
      end
    end
  end
end
