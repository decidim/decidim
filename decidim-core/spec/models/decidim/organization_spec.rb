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

        it { is_expected.to be_valid }
      end

      context "when the homepage image is a malicious image" do
        let(:homepage_image_path) {
          File.expand_path(
            File.join(File.dirname(__FILE__), "..", "..", "..", "..", "decidim-dev", "spec", "support", "malicious.jpg")
          )
        }
        subject do
          build(
            :organization,
            homepage_image: Rack::Test::UploadedFile.new(homepage_image_path, "image/jpg")
          )
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
