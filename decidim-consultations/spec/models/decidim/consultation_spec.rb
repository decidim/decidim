# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Consultation do
    subject { consultation }

    let(:consultation) { build(:consultation, slug: "my-slug") }

    include_examples "resourceable"

    it { is_expected.to be_valid }

    it "Uses slug when is used as a parameter" do
      expect(consultation.to_param).to eq(consultation.slug)
    end

    describe "upcoming?" do
      context "when voting period starts in the future" do
        let(:consultation) { build(:consultation, :upcoming) }

        it "is upcoming" do
          expect(consultation).to be_upcoming
          expect(consultation).not_to be_active
          expect(consultation).not_to be_finished
        end
      end
    end

    describe "active?" do
      context "when today is inside the voting interval" do
        let(:consultation) { build(:consultation, :active) }

        it "is active" do
          expect(consultation).not_to be_upcoming
          expect(consultation).to be_active
          expect(consultation).not_to be_finished
        end
      end
    end

    describe "finished?" do
      context "when today is after the voting end time" do
        let(:consultation) { build(:consultation, :finished) }

        it "is active" do
          expect(consultation).not_to be_upcoming
          expect(consultation).not_to be_active
          expect(consultation).to be_finished
        end
      end
    end

    include_examples "publicable"

    context "when there's a consultation with the same slug in the same organization" do
      let!(:external_assembly) { create :consultation, organization: consultation.organization, slug: "my-slug" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there's a consultation with the same slug in another organization" do
      let!(:external_assembly) { create :consultation, slug: "my-slug" }

      it { is_expected.to be_valid }
    end
  end
end
