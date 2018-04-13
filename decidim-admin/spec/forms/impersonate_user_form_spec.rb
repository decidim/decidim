# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImpersonateUserForm do
      subject do
        described_class.from_params(
          attributes.merge(extra_attributes)
        ).with_context(
          current_organization: organization
        )
      end

      let(:organization) { create :organization }
      let(:user) { create(:user, organization: organization) }
      let(:document_number) { "12345678X" }

      let(:authorization) do
        AuthorizationHandler.handler_for(
          "dummy_authorization_handler",
          document_number: document_number,
          user: user
        )
      end
      let(:attributes) do
        {
          authorization: authorization
        }
      end
      let(:extra_attributes) do
        { user: user }
      end

      it { is_expected.to be_valid }

      context "when no user is passed" do
        let(:extra_attributes) do
          {}
        end

        it { is_expected.to be_invalid }
      end

      context "when authorization already exists for another user in the organization" do
        before do
          create(
            :authorization,
            user: create(:user, organization: organization),
            name: "dummy_authorization_handler",
            unique_id: document_number
          )
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
