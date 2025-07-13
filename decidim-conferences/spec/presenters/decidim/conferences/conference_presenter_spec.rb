# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conferences::ConferencePresenter do
    subject { described_class.new(conference) }

    let!(:conference) { create(:conference) }
    let(:organization_host) { conference.organization.host }

    describe "when no images were uploaded" do
      before do
        conference.hero_image.purge
        conference.banner_image.purge
      end

      it "return nil for hero_image_url" do
        expect(subject.hero_image_url).to be_nil
      end

      it "return nil for banner_image_url" do
        expect(subject.banner_image_url).to be_nil
      end
    end

    describe "when images are attached" do
      it "resolves hero_image_url" do
        expect(subject.hero_image_url).to be_blob_url(conference.hero_image.blob)
      end

      it "resolves banner_image_url" do
        expect(subject.banner_image_url).to be_blob_url(conference.banner_image.blob)
      end
    end
  end
end
