# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LayoutHelper do
    let(:helper) do
      Class.new(ActionView::Base) do
        include LayoutHelper
        include SanitizeHelper
        include TranslatableAttributes
      end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
    end

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

    describe "#organization_description_label" do
      subject { helper.organization_description_label }
      before do
        allow(helper).to receive(:current_organization).and_return(organization)
      end

      context "when the organization does not have a description" do
        let(:organization) { create(:organization, description: { en: nil }) }

        it "shows the default message" do
          expect(subject).to eq("Let's build a more open, transparent and collaborative society.<br /> Join, participate and decide.")
        end
      end

      context "when the organization have a description with an empty paragraph" do
        let(:organization) { create(:organization, description: { en: "<p></p>" }) }

        it "shows the default message" do
          expect(subject).to eq("Let's build a more open, transparent and collaborative society.<br /> Join, participate and decide.")
        end
      end

      context "when the organization has a description" do
        let(:organization) { create(:organization) }

        it "shows the organization description" do
          expect(subject).to have_text(strip_tags(translated(organization.description)))
        end
      end
    end
  end
end
