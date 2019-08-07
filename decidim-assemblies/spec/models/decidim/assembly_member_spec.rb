# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyMember do
    subject { assembly_member }

    let(:assembly_member) { build(:assembly_member) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    describe ".default_scope" do
      it "returns members ordered by weight" do
        assembly_member1 = create(:assembly_member, weight: 3)
        assembly_member2 = create(:assembly_member, weight: 1)
        assembly_member3 = create(:assembly_member, weight: 2)

        expected_result = [
          assembly_member2,
          assembly_member3,
          assembly_member1
        ]

        expect(described_class.all).to eq expected_result
      end
    end

    describe "#participatory_space" do
      it "is an alias for #assembly" do
        expect(assembly_member.assembly).to eq assembly_member.participatory_space
      end
    end
  end
end
