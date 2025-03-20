# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe BlockUserForm do
      let(:organization) { create(:organization) }
      let(:justification) { "" }

      shared_examples "blocking a user or group" do
        describe "from a model" do
          subject do
            described_class.from_model(
              user
            ).with_context(
              current_organization: organization
            )
          end

          context "when justification form is empty" do
            it { is_expected.not_to be_valid }
          end
        end

        describe "from params" do
          subject do
            described_class.from_params(
              justification:, user_id: user.id
            ).with_context(
              current_organization: organization
            )
          end

          context "when justification has the correct length" do
            let(:justification) { "Not TOS compliant." }

            it { is_expected.to be_valid }
          end

          context "when justification is too short" do
            let(:justification) { "Not TOS." }

            it { is_expected.not_to be_valid }
          end

          context "when the user does not exist" do
            let(:user_id) { 9999 }

            it { is_expected.not_to be_valid }
          end
        end
      end

      context "with a user" do
        let(:user) { create(:user, organization:) }

        it_behaves_like "blocking a user or group"
      end

      context "with a user group" do
        let(:user) { create(:user_group, organization:) }

        it_behaves_like "blocking a user or group"
      end
    end
  end
end
