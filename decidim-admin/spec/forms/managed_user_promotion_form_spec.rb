# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ManagedUserPromotionForm do
      subject do
        described_class.from_params(attributes).with_context(
          current_organization: current_organization,
          current_user: user
        )
      end

      let(:current_organization) { create(:organization) }
      let!(:user) { create :user, :confirmed, organization: current_organization }

      let(:email) { "foo@example.org" }
      let(:attributes) do
        {
          "managed_user_promotion" => {
            "email" => email
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when email is missing" do
        let(:email) { nil }

        it { is_expected.to be_invalid }
      end

      context "when email already exist" do
        let!(:another_user) { create :user, :confirmed, email: email, organization: current_organization }

        it { is_expected.to be_invalid }
      end
    end
  end
end
