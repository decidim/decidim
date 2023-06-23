# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LayoutHelper do
    describe "#external_icon" do
      subject { helper.external_icon(path) }

      context "when the icon exists" do
        let(:path) { "media/images/google.svg" }

        it "returns the SVG element" do
          expect(subject).to match(/^<svg.*/)
        end
      end

      context "when the icon does not exist" do
        let(:path) { "media/images/hooli.svg" }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when the icon exists in the manifest but not in the file system" do
        let(:path) { "media/images/google.svg" }

        before do
          allow(helper).to receive(:asset_pack_path).and_return("/unexisting/path.svg")
        end

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when using a custom host" do
        let(:path) { "media/images/google.svg" }

        before do
          allow(helper.config).to receive(:asset_host).and_return("https://assets.example.org")
        end

        # Ensures the asset_path_pack would normally return the asset host in
        # case there are any API changes in Rails.
        it "works expectedly" do
          expect(helper.asset_pack_path(path)).to match(%r{^https://assets.example.org/packs-test})
        end

        it "returns the SVG element" do
          expect(subject).to match(/^<svg.*/)
        end
      end
    end

    describe "#application_path" do
      subject { helper.application_path(path) }

      context "when the icon exists" do
        let(:path) { "media/images/google.svg" }

        it "returns the file path to the asset" do
          expect(subject.to_s).to match(
            %r{^#{Rails.public_path}/packs-test/media/images/google-[a-z0-9]+\.svg}
          )
        end
      end

      context "when the icon does not exist" do
        let(:path) { "media/images/hooli.svg" }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when the icon exists in the manifest but not in the file system" do
        let(:path) { "media/images/google.svg" }

        before do
          allow(helper).to receive(:asset_pack_path).and_return("/unexisting/path.svg")
        end

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when using a custom host" do
        let(:path) { "media/images/google.svg" }

        before do
          allow(helper.config).to receive(:asset_host).and_return("https://assets.example.org")
        end

        # Ensures the asset_path_pack would normally return the asset host in
        # case there are any API changes in Rails.
        it "works expectedly" do
          expect(helper.asset_pack_path(path)).to match(%r{^https://assets.example.org/packs-test})
        end

        it "returns the file path to the asset" do
          expect(subject.to_s).to match(
            %r{^#{Rails.public_path}/packs-test/media/images/google-[a-z0-9]+\.svg}
          )
        end
      end
    end

    describe "#emojibase_entrypoint_locale" do
      subject { helper.emojibase_entrypoint_locale }
      let(:entrypoints) do
        {
          "decidim_emojibase_en" => "path/to/decidim_emojibase_en.js",
          "decidim_emojibase_es" => "path/to/decidim_emojibase_es.js"
        }
      end

      before do
        allow(Decidim::Webpacker.configuration).to receive(:entrypoints).and_return(entrypoints)
        allow(I18n).to receive(:locale).and_return(locale)
      end

      context "when it is a supported locale" do
        let(:locale) { :es }

        it { is_expected.to eq("decidim_emojibase_es") }
      end

      context "when it is not a supported locale" do
        let(:locale) { :ca }

        it { is_expected.to eq("decidim_emojibase_en") }
      end
    end
  end
end
