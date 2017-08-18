# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization, processing_uploads_for: Decidim::HomepageImageUploader do
    let(:organization) { build(:organization) }

    subject { organization }

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
        let(:homepage_image_path) { Decidim::Dev.asset("malicious.jpg") }

        subject do
          build(
            :organization,
            homepage_image: Rack::Test::UploadedFile.new(homepage_image_path, "image/jpg")
          )
        end

        it { is_expected.not_to be_valid }
      end

      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end
    end
  end
end
