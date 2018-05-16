# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcess do
    subject { participatory_process }

    let(:participatory_process) { build(:participatory_process, slug: "my-slug") }

    it { is_expected.to be_valid }

    it { is_expected.to be_versioned }

    include_examples "publicable"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessPresenter
    end

    context "when there's a process with the same slug in the same organization" do
      let!(:external_process) { create :participatory_process, organization: participatory_process.organization, slug: "my-slug" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there's a process with the same slug in another organization" do
      let!(:external_process) { create :participatory_process, slug: "my-slug" }

      it { is_expected.to be_valid }
    end

    describe "#past?" do
      context "when it ends in the past" do
        it "returns true" do
          participatory_process.end_date = 1.day.ago
          expect(participatory_process).to be_past
        end
      end

      context "when it ends in the future" do
        it "returns false" do
          participatory_process.end_date = 1.day.from_now
          expect(participatory_process).not_to be_past
        end
      end

      context "when it doesn't have an end date" do
        it "returns false" do
          participatory_process.end_date = nil
          expect(participatory_process).not_to be_past
        end
      end
    end
  end
end
