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
  end
end
