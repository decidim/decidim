# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Admin::AssemblyMemberPresenter, type: :helper do
    let(:assembly_member) do
      build(:assembly_member, full_name: "Full name")
    end

    describe "name" do
      subject { described_class.new(assembly_member).name }

      it { is_expected.to eq "Full name" }

      context "when member is an existing user" do
        let(:user) { build(:user, name: "Julia G.", nickname: "julia_g") }
        let(:assembly_member) { build(:assembly_member, full_name: "Full name", user: user) }

        it { is_expected.to eq "Julia G. (@julia_g)" }
      end
    end
  end
end
