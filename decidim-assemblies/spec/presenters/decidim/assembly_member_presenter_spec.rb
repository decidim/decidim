# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyMemberPresenter, type: :helper do
    let(:assembly_member) { build(:assembly_member, full_name: "Full name") }

    describe "#gender" do
      subject { described_class.new(assembly_member).gender }

      it { is_expected.to eq t(assembly_member.gender, scope: "decidim.admin.models.assembly_member.genders") }
    end

    describe "#position" do
      subject { described_class.new(assembly_member).position }

      context "when position is predefined" do
        it { is_expected.to eq t(assembly_member.position, scope: "decidim.admin.models.assembly_member.positions") }
      end

      context "when position is other" do
        let(:assembly_member) { build(:assembly_member, position: "other", position_other: "Custom position") }

        it "show the custom position value" do
          expect(subject).to eq("Custom position")
        end
      end
    end
  end
end
