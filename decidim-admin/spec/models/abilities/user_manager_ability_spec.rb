# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::UserManagerAbility do
    subject { described_class.new(user, {}) }

    let(:organization) { create(:organization, available_authorizations: available_authorizations) }
    let(:available_authorizations) { ["dummy_authorization_handler"] }
    let(:user) { create(:user, :user_manager, organization: organization) }
    let(:impersonated_user) { create(:user, organization: organization) }

    context "when the organization has authorization handlers" do
      it "can impersonate" do
        expect(subject).to be_able_to(:impersonate, impersonated_user)
      end
    end

    context "when the organization doesn't have authorizations" do
      let(:available_authorizations) { [] }

      it "can't impersonate" do
        expect(subject).not_to be_able_to(:impersonate, impersonated_user)
      end
    end

    context "when the organization has only authorization workflows" do
      let(:available_authorizations) { ["dummy_authorization_workflow"] }

      it "can't impersonate" do
        expect(subject).not_to be_able_to(:impersonate, impersonated_user)
      end
    end

    context "when the user is not a user manager" do
      let(:user) { create(:user, organization: organization) }

      it "doesn't have any permission" do
        expect(subject.permissions[:can]).to be_empty
        expect(subject.permissions[:cannot]).to be_empty
      end
    end

    context "when the user doesn't have an impersonation log" do
      before do
        create(:impersonation_log, admin: create(:user, organization: organization))
      end

      it { is_expected.to be_able_to(:impersonate, impersonated_user) }
    end

    context "when the user doesn't have an active impersonation log" do
      before do
        create(:impersonation_log, admin: user, started_at: 2.days.ago, ended_at: 1.day.ago)
      end

      it { is_expected.to be_able_to(:impersonate, impersonated_user) }
    end

    context "when the user has an active impersonation log" do
      before do
        create(:impersonation_log, admin: user, started_at: 10.minutes.ago)
      end

      it { is_expected.not_to be_able_to(:impersonate, impersonated_user) }
    end

    context "when the impersonated user is an admin" do
      let(:impersonated_user) { create(:user, :admin, organization: organization) }

      it { is_expected.not_to be_able_to(:impersonate, impersonated_user) }
    end

    context "when the impersonated user is a user manager" do
      let(:impersonated_user) { create(:user, :user_manager, organization: organization) }

      it { is_expected.not_to be_able_to(:impersonate, impersonated_user) }
    end

    it { is_expected.to be_able_to(:read, :impersonatable_users) }
  end
end
