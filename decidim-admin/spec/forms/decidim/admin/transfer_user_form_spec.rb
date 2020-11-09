# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TransferUserForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization
        )
      end

      let(:organization) { create :organization }
      let(:managed_user) { create(:user, managed: true, organization: organization) }
      let(:user) { create(:user, managed: true, organization: organization) }

      let(:attributes) do
        {
          user: user,
          managed_user: managed_user
        }
      end

      context "when no user is passed" do
        let(:user) {}

        it { is_expected.to be_invalid }
      end

      context "when no managed user is passed" do
        let(:managed_user) {}

        it { is_expected.to be_invalid }
      end
    end
  end
end
