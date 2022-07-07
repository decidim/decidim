# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingRegistrationInviteForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create :organization }
    let(:context) do
      {
        current_organization: organization
      }
    end

    let(:name) { "Foo" }
    let(:email) { "foo@example.org" }
    let(:existing_user) { false }
    let(:user_id) { nil }
    let(:attributes) do
      {
        name: name,
        email: email,
        existing_user: existing_user,
        user_id: user_id
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is missing" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when email is missing" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when existing user is present" do
      let(:existing_user) { true }

      context "and no user is provided" do
        it { is_expected.to be_invalid }
      end

      context "and user exists" do
        let(:user_id) { create(:user, organization: organization).id }

        it { is_expected.to be_valid }
      end

      context "and no such user exists" do
        let(:user_id) { 999_999 }

        it { is_expected.to be_invalid }
      end

      describe "user" do
        subject { form.user }

        context "when the user exists" do
          let(:user_id) { create(:user, organization: organization).id }

          it { is_expected.to be_kind_of(Decidim::User) }
        end

        context "when the user does not exist" do
          let(:user_id) { 999_999 }

          it { is_expected.to be_nil }
        end

        context "when the user is from another organization" do
          let(:user_id) { create(:user).id }

          it { is_expected.to be_nil }
        end
      end
    end
  end
end
