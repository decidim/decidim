# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::IdDocuments
  describe InformationForm do
    subject do
      described_class.new(
        verification_type:,
        document_type:,
        document_number:
      )
    end

    let(:user) { create(:user) }

    let(:verification_type) { "online" }
    let(:document_type) { "DNI" }
    let(:document_number) { "XXXXXXXXY" }

    context "when the information is valid" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when verification type is invalid" do
      let(:verification_type) { "invalid type" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:verification_type]).to include("is not included in the list")
      end
    end

    context "when document type is invalid" do
      let(:document_type) { "driver's license" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:document_type]).to include("is not included in the list")
      end
    end

    context "when the document format is invalid" do
      let(:document_number) { "XXXXXXXX-Y" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:document_number])
          .to include("must be all uppercase and contain only letters and/or numbers")
      end
    end
  end
end
