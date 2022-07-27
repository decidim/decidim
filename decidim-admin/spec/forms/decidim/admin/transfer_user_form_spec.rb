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
      let(:current_user) { create :user, :admin, organization: }
      let(:new_user) { create :user, organization: }
      let(:managed_user) { create :user, managed: true, organization: }

      let(:conflict) do
        Decidim::Verifications::Conflict.create(current_user: new_user, managed_user:)
      end

      let(:attributes) do
        {
          current_user:,
          conflict:
        }
      end

      context "when form is valid" do
        it { is_expected.to be_valid }
      end

      context "when no current_user is passed" do
        let(:current_user) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no conflict is passed" do
        let(:conflict) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
