# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessPresenter do
    subject { described_class.new(process) }

    let!(:process) { create(:participatory_process) }

    describe "#hero_image_url" do
      context "when there's no image" do
        it "returns nil" do
          allow(process).to receive(:hero_image_url).and_return(nil)

          expect(subject.hero_image_url).to be_nil
        end
      end

      context "when image is a full url" do
        it "returns nil" do
          image_url = "http://example.com/image.jpg"
          allow(process).to receive(:hero_image_url).and_return(image_url)

          expect(subject.hero_image_url).to eq(image_url)
        end
      end

      context "when image is a partial path" do
        it "returns nil" do
          organization_host = "http://example.org"
          image_path = "/my/image.jpg"
          allow(process).to receive(:hero_image_url).and_return(image_path)
          allow(process.organization).to receive(:host).and_return(organization_host)

          expect(subject.hero_image_url).to eq("http://example.org/my/image.jpg")
        end
      end
    end

    describe "#banner_image_url" do
      context "when there's no image" do
        it "returns nil" do
          allow(process).to receive(:banner_image_url).and_return(nil)

          expect(subject.banner_image_url).to be_nil
        end
      end

      context "when image is a full url" do
        it "returns nil" do
          image_url = "http://example.com/image.jpg"
          allow(process).to receive(:banner_image_url).and_return(image_url)

          expect(subject.banner_image_url).to eq(image_url)
        end
      end

      context "when image is a partial path" do
        it "returns nil" do
          organization_host = "http://example.org"
          image_path = "/my/image.jpg"
          allow(process).to receive(:banner_image_url).and_return(image_path)
          allow(process.organization).to receive(:host).and_return(organization_host)

          expect(subject.banner_image_url).to eq("http://example.org/my/image.jpg")
        end
      end
    end
  end
end
