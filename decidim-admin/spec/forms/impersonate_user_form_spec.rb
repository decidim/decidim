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
      let(:authorization) do
        {
          handler_name: "dummy_authorization_handler",
          document_number: "12345678X"
        }
      end
      let(:attributes) do
        {
          authorization: authorization
        }
      end
      let(:extra_attributes) do
        {}
      end

      context "when no new managed user name nor managed user id passed" do
        it { is_expected.to be_invalid }
      end

      context "when a new managed user is passed" do
        let(:name) { "Peter Parker" }

        let(:extra_attributes) do
          { name: name }
        end

        context "and it's an existing managed user" do
          before { create(:user, name: name, organization: organization, managed: true) }

          it { is_expected.to be_valid }
        end

        context "and it's an non existing managed user" do
          it { is_expected.to be_valid }
        end
      end

      context "when an existing user is passed" do
        let(:extra_attributes) do
          { user: create(:user, organization: organization) }
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
