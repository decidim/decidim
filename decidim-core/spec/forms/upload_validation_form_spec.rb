# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UploadValidationForm do
    subject { form }

    let(:params) do
      {
        resource_class: resource_class,
        property: property,
        blob: blob,
        form_class: form_class
      }
    end
    let(:form) do
      described_class.from_params(params)
    end

    let(:resource_class) { "Decidim::DummyResources::DummyResource" }
    let(:property) { "avatar" }
    let(:blob) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:form_class) { "Decidim::DummyResources::DummyForm" }

    let(:passthru_validator) do
      double(
        validate_each: validate_each
      )
    end
    let(:validate_each) { double }

    before do
      allow(PassthruValidator).to receive(:new).and_return(passthru_validator)
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when property is missing" do
      let(:property) { nil }

      it "is invalid" do
        expect(subject.invalid?).to be(true)
      end
    end

    context "when blob is missing" do
      let(:blob) { nil }

      it "is invalid" do
        expect(subject.invalid?).to be(true)
      end
    end

    context "when resouce class is missing" do
      let(:resource_class) { nil }

      it "is invalid" do
        expect(subject.invalid?).to be(true)
      end
    end
  end
end
