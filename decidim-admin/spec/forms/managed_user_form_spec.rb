# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ManagedUserForm do
      let(:organization) { create :organization }
      let(:name) { "Foo" }
      let(:authorization) do
        {
          handler_name: "decidim/dummy_authorization_handler",
          document_number: "12345678X"
        }
      end
      let(:attributes) do
        {
          name: name,
          authorization: authorization
        }
      end
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the name is not present" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the authorization already exists for another user" do
        before do
          Authorization.create!(
            user: create(:user, organization: organization),
            name: authorization[:handler_name],
            unique_id: authorization[:document_number]
          )
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
