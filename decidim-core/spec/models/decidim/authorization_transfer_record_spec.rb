# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationTransferRecord do
    subject { record }

    let(:record) { build(:authorization_transfer_record) }

    it { is_expected.to be_valid }

    context "without transfer" do
      let(:record) { build(:authorization_transfer_record, transfer: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without resource" do
      let(:record) { build(:authorization_transfer_record, resource: nil) }

      it { is_expected.not_to be_valid }
    end

    describe "#readonly?" do
      subject { record.readonly? }

      it "returns true for a persisted record" do
        record.save!
        expect(subject).to be(true)
      end

      it "returns false for a new record" do
        expect(subject).to be(false)
      end
    end

    describe "#type" do
      subject { record.type }

      it "returns the resource type class as string" do
        expect(subject).to eq("Decidim::DummyResources::DummyResource")
      end

      context "when the resource responds to resource_type" do
        let(:record) { build(:authorization_transfer_record, resource: coauthorship) }
        let(:coauthorship) { build(:coauthorship) }

        it "returns the resource type reported by the record" do
          expect(subject).to eq("Decidim::DummyResources::DummyResource")
        end
      end
    end
  end
end
