# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe OrganizationDashboardConstraint do
      let(:organization) { create(:organization) }
      let(:request) do
        double(
          env: {
            "decidim.current_organization" => organization,
            "warden" => warden
          }
        )
      end
      let(:warden) do
        double(
          authenticate!: authenticated,
          user: user
        )
      end

      subject { described_class.new(request).matches? }

      context "when authenticated" do
        let(:authenticated) { true }

        context "a regular user" do
          let(:user) { create(:user, :confirmed, organization: organization) }

          it { is_expected.to be_falsey }
        end

        context "an organization admin" do
          let(:user) { create(:user, :confirmed, :admin, organization: organization) }
          it { is_expected.to be_truthy }
        end

        context "an admin from another organization" do
          let(:other_organization) { create(:organization) }
          let(:user) { create(:user, :confirmed, :admin, organization: other_organization) }

          it { is_expected.to be_falsey }
        end
      end

      describe "when unauthenticated" do
        let(:authenticated) { false }
        let(:user) { nil }

        it { is_expected.to be_falsey }
      end
    end
  end
end
