# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcess do
    let(:participatory_process) { build(:participatory_process, slug: "my-slug") }
    subject { participatory_process }

    it { is_expected.to be_valid }

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

    context "scopes" do
      let(:organization) { create :organization }
      let!(:scope) { create :scope, organization: organization }
      let(:participatory_process) { build(:participatory_process, organization: organization, scope_ids: [scope.id]) }

      it "finds the related scopes" do
        expect(subject.scopes).to eq [scope]
      end
    end
  end
end
