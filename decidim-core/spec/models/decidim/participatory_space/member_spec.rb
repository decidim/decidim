# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatorySpace
  describe Member do
    subject { member }

    let(:member) { build(:member) }

    it { is_expected.to be_valid }

    context "when the participatory space and user belongs to different organizations" do
      let(:participatory_space_organization) { create(:organization) }
      let(:user_organization) { create(:organization) }

      let(:participatory_process) do
        build(
          :participatory_process,
          organization: participatory_space_organization
        )
      end

      let(:user) { create(:user, organization: user_organization) }

      let(:member) do
        build(
          :member,
          user:,
          participatory_space: participatory_process
        )
      end

      it { is_expected.not_to be_valid }
    end

    describe ".ransackable_attributes" do
      let(:admin) { build(:user, :admin, :confirmed) }

      it "allows admins to sort by published" do
        expect(described_class.ransackable_attributes(admin)).to include("published")
      end
    end
  end
end
