# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::UserManagerAbility do
    subject { described_class.new(user, {}) }

    let(:organization) { create(:organization, available_authorizations: ["dummy"]) }
    let(:user) { create(:user, :user_manager, organization: organization) }

    context "when the organization has authorizations" do
      it "can create new managed users" do
        expect(subject).to be_able_to(:new, :managed_users)
        expect(subject).to be_able_to(:create, :managed_users)
      end
    end

    context "when the organization doesn't have authorizations" do
      let(:organization) { create(:organization, available_authorizations: []) }

      it "can't create new managed users" do
        expect(subject).not_to be_able_to(:new, :managed_users)
        expect(subject).not_to be_able_to(:create, :managed_users)
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
      let(:managed) { create(:user, :managed, organization: organization) }

      before do
        create(:impersonation_log, admin: create(:user, organization: organization))
      end

      it { is_expected.to be_able_to(:impersonate, managed) }
    end

    context "when the user doesn't have an active impersonation log" do
      let(:managed) { create(:user, :managed, organization: organization) }

      before do
        create(:impersonation_log, admin: user, started_at: 2.days.ago, ended_at: 1.day.ago)
      end

      it { is_expected.to be_able_to(:impersonate, managed) }
    end

    context "when the user has an active impersonation log" do
      let(:managed) { create(:user, :managed, organization: organization) }

      before do
        create(:impersonation_log, admin: user, started_at: 10.minutes.ago)
      end

      it { is_expected.not_to be_able_to(:impersonate, managed) }
    end

    it { is_expected.to be_able_to(:manage, :managed_users) }
  end
end
