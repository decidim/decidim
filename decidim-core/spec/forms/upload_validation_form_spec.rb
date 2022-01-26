# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UploadValidationForm do
    subject { form }

    let(:params) do
      {
        resource: resource,
        property: property,
        blob: blob,
        klass: klass
      }
    end
    let(:form) do
      described_class.from_params(params)
    end

    let(:resource) { "Decidim::DummyResources::DummyResource" }
    let(:property) { "avatar" }
    let(:blob) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:klass) { "Decidim::DummyResources::DummyForm" }

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

    context "when validation fails" do
      let(:passthru_validator) { DummyPassthruValidator.new }

      it "is invalid" do
        expect(subject.invalid?).to eq(true)
      end
    end

    class DummyPassthruValidator
      def validate_each(record, attribute, _value)
        record.errors.add(attribute, "Dummy error")
      end
    end
  end
end
