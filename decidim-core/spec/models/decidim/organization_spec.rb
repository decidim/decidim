# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Organization do
    let(:organization) { build(:organization) }

    subject { organization}

    before do
      Decidim::HomepageImageUploader.enable_processing = true
    end

    it { is_expected.to be_valid }

    describe "validations" do
      context "when the homepage image is not present" do
        subject do
          build(
            :organization,
            homepage_image: nil
          )
        end

        it { is_expected.not_to be_valid }
      end

      context "when the homepage image is too big" do
        before do
          expect(subject.homepage_image).to receive(:size).and_return(11.megabytes)
        end

        it { is_expected.to_not be_valid }
      end

      context "when the homepage image is a malicious image" do
        subject do
          build(
            :organization,
            homepage_image: Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "decidim-dev", "spec", "support", "malicious.jpg"), "image/jpg")
          )
        end

        it { is_expected.to_not be_valid }
      end
    end
  end
end
