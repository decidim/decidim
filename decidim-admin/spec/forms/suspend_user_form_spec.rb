# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SuspendUserForm do
      let(:organization) { create(:organization) }

      let(:user) { create(:user, organization: organization) }

      subject do
        described_class.from_model(
          user
        ).with_context(
          current_organization: organization
        )
      end

      context "when justification has the correct length" do
        let(:justification) { "Not TOS compliant." }

        subject do
          described_class.from_params(
            justification: justification, user_id: user.id
          ).with_context(
            current_organization: organization
          )
        end

        it { is_expected.to be_valid }
      end

      context "when justification is too short" do
        let(:justification) { "Not TOS." }

        subject do
          described_class.from_params(
            justification: justification, user_id: user.id
          ).with_context(
            current_organization: organization
          )
        end

        it { is_expected.not_to be_valid }
      end

      context "when justification form is empty" do
        let(:justification) { "" }

        it { is_expected.not_to be_valid }
      end

      context "when the user does not exist" do
        let(:user_id) { 9999 }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
