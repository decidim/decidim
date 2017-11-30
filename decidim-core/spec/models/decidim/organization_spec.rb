# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization, processing_uploads_for: Decidim::HomepageImageUploader do
    subject(:organization) { build(:organization) }

    it { is_expected.to be_valid }

    describe "has an association for scopes" do
      subject(:organization_scopes) { organization.scopes }

      let(:scopes) { create_list(:scope, 2, organization: organization) }

      it { is_expected.to contain_exactly(*scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization: organization) }

      it { is_expected.to contain_exactly(*scope_types) }
    end

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
        subject do
          build(
            :organization,
            homepage_image: Rack::Test::UploadedFile.new(homepage_image_path, "image/jpg")
          )
        end

        let(:homepage_image_path) { Decidim::Dev.asset("malicious.jpg") }

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
