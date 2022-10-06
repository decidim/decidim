# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatorySpacePrivateUser do
    subject { participatory_space_private_user }

    let(:participatory_space_private_user) { build(:participatory_space_private_user) }

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

      let(:participatory_space_private_user) do
        build(
          :participatory_space_private_user,
          user:,
          privatable_to: participatory_process
        )
      end

      it { is_expected.not_to be_valid }
    end
  end
end
