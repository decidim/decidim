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
    let(:pad) { instance_double(Decidim::Etherpad::Pad, id: "pad-id", read_only_id: "read-only-id") }
    let(:salt) { "super-secret" }

    before do
      allow(Decidim).to receive(:etherpad).and_return(etherpad_config)
      paddable.component.settings = { enable_pads_creation: true }
    end

    describe "pad_public_url" do
      before do
        allow(paddable).to receive(:pad).and_return(pad)
      end

      context "when there is no pad" do
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

      context "when there is no pad" do
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
      context "when there is no Etherpad service configured" do
        let(:etherpad_config) { nil }

        it "returns nil" do
          expect(paddable.pad).to be_nil
        end
      end

      context "when the component has not enabled pads" do
        before do
          paddable.component.settings = { enable_pads_creation: false }
        end

        it "returns nil" do
          expect(paddable.pad).to be_nil
        end
      end

      # Testing some private methods to ensure compatibility with old pad id generation
      context "when pad_id is auto-generated" do
        before do
          allow(paddable).to receive(:id).and_return(12_345)
          allow(paddable).to receive(:reference).and_return("REF")
        end

        context "when salt is undefined" do
          it "returns unsecure hash" do
            expect(paddable.send(:pad_id)).to eq("REF-#{unsecure_hash(12_345)}".slice(0, 50))
          end
        end

        context "when salt is empty" do
          before do
            allow(paddable).to receive(:salt).and_return("")
          end

          it "returns unsecure hash" do
            expect(paddable.send(:pad_id)).to eq("REF-#{unsecure_hash(12_345)}".slice(0, 50))
          end
        end

        context "when salt is present" do
          before do
            allow(paddable).to receive(:salt).and_return(salt)
          end

          it "returns secure hash" do
            expect("REF-#{secure_hash(12_345)}").to include(paddable.send(:pad_id))
          end
        end
      end

      def unsecure_hash(id)
        Digest::SHA256.hexdigest("#{id}-#{Rails.application.secret_key_base}")
      end

      def secure_hash(id)
        Decidim::Tokenizer.new(salt:).hex_digest(id)
      end
    end
  end
end
