# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyPrivateUser do
    subject { assembly_private_user }

    let(:assembly_private_user) { build(:assembly_private_user) }

    it { is_expected.to be_valid }

    context "when the assembly and user belongs to different organizations" do
      let(:assembly_organization) { create(:organization) }
      let(:user_organization) { create(:organization) }

      let(:assembly) do
        build(
          :assembly,
          organization: assembly_organization
        )
      end

      let(:user) { create(:user, organization: user_organization) }

      let(:assembly_private_user) do
        build(
          :assembly_private_user,
          user: user,
          assembly: assembly
        )
      end

      it { is_expected.not_to be_valid }
    end
  end
end
