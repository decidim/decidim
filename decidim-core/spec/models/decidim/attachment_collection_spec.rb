# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttachmentCollection do
    subject { attachment_collection }

    let(:attachment_collection) { build(:attachment_collection) }

    it { is_expected.to be_valid }

    context "without a collection holder" do
      let(:attachment_collection) { build(:attachment_collection, collection_for: nil) }

      it { is_expected.not_to be_valid }

      it "adds an error" do
        subject.valid?
        expect(subject.errors[:collection_for]).to eq ["must exist"]
      end
    end
  end
end
