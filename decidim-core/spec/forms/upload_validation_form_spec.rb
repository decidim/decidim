# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UploadValidationForm do
    subject { form }

    let(:params) do
      {
        resource_class:,
        property:,
        blob:,
        form_class:
      }
    end
    let(:form) do
      described_class.from_params(params)
    end

    let(:resource_class) { "Decidim::Dev::DummyResource" }
    let(:property) { "avatar" }
    let(:blob) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:form_class) { "Decidim::Dev::DummyForm" }

    let(:passthru_validator) do
      double(
        validate_each:
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

    context "when resource class is missing" do
      let(:resource_class) { nil }

      it "is invalid" do
        expect(subject.invalid?).to be(true)
      end
    end

    context "when resource class is ContentBlockAttachment" do
      let(:resource_class) { "Decidim::ContentBlockAttachment" }
      let(:property) { "background_image" }
      let(:form_class) { nil }

      context "with a valid image file" do
        it "accepts a jpeg image" do
          expect(subject).to be_valid
        end

        it "accepts a png image" do
          form = described_class.from_params(params.merge(blob: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/png"), filename: "photo.png")))
          expect(form).to be_valid
        end

        it "accepts a webp image" do
          form = described_class.from_params(params.merge(blob: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/webp"), filename: "photo.webp")))
          expect(form).to be_valid
        end
      end

      context "with a non-image file" do
        it "rejects a pdf file" do
          form = described_class.from_params(params.merge(blob: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "plan.pdf")))
          expect(form.invalid?).to be(true)
          expect(form.errors.full_messages.first).to include("jpeg, jpg, png, webp")
        end

        it "rejects a docx file" do
          form = described_class.from_params(params.merge(blob: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "document.docx")))
          expect(form.invalid?).to be(true)
          expect(form.errors.full_messages.first).to include("jpeg, jpg, png, webp")
        end
      end
    end
  end
end
