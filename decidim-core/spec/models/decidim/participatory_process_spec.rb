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

    describe "#admins" do
      let!(:admin) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
      let!(:participatory_process_admin) do
        user = create(:user, :confirmed, organization: participatory_process.organization)
        Decidim::Admin::ParticipatoryProcessUserRole.create!(
          role: :admin,
          user: user,
          participatory_process: participatory_process
        )
        user
      end

      it "returns the organization admins and participatory process admins" do
        expect(participatory_process.admins).to match_array([admin, participatory_process_admin])
      end
    end
  end
end
