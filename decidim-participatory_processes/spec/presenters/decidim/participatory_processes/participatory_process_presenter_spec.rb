# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessPresenter do
    subject { described_class.new(process) }

    let!(:process) { create(:participatory_process) }

    describe "#hero_image_url" do
      context "when there is no image" do
        before do
          process.hero_image.purge
        end

        it "returns nil" do
          expect(subject.hero_image_url).to be_nil
        end
      end

      context "when image is attached" do
        it "returns an URL including the organization domain" do
          expect(subject.hero_image_url).to include(process.organization.host)
          expect(subject.hero_image_url).to be_blob_url(process.hero_image.blob)
        end
      end
    end
  end
end
