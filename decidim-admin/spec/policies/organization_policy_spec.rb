require "spec_helper"

module Decidim
  module Admin
    describe OrganizationPolicy do
      let(:organization) { create(:organization) }

      subject { described_class.new(user, organization) }

      context "within the same organization" do
        context "being a regular user" do
          let(:user) { create(:user, organization: organization) }

          it { is_expected.to forbid_action(:update) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: organization) }

          it { is_expected.to permit_action(:update) }
        end
      end

      context "in another organization" do
        let(:other_organization) { create(:organization) }

        context "being a regular user" do
          let(:user) { create(:user, organization: other_organization) }

          it { is_expected.to forbid_action(:update) }
        end

        context "being an admin" do
          let(:user) { create(:user, :admin, organization: other_organization) }

          it { is_expected.to forbid_action(:update) }
        end
      end
    end
  end
end
