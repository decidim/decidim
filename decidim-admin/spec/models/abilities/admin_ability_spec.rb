# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::AdminAbility do
    subject { described_class.new(user, {}) }

    let(:organization) { create(:organization, available_authorizations: available_authorizations) }
    let(:available_authorizations) { ["dummy_authorization_handler"] }
    let(:user) { build(:user, :admin, organization: organization) }
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

    context "when the user is not an admin" do
      let(:user) { build(:user) }

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

    it { is_expected.to be_able_to(:read, :admin_log) }
    it { is_expected.to be_able_to(:read, :impersonatable_users) }

    it { is_expected.to be_able_to(:manage, Decidim::Moderation) }
    it { is_expected.to be_able_to(:manage, Decidim::Attachment) }
    it { is_expected.to be_able_to(:manage, Decidim::Scope) }
    it { is_expected.to be_able_to(:manage, :admin_users) }

    it { is_expected.to be_able_to(:manage, :oauth_applications) }
    it { is_expected.to be_able_to(:manage, Decidim::OAuthApplication) }

    it { is_expected.to be_able_to(:create, Decidim::StaticPage) }
    it { is_expected.to be_able_to(:update, Decidim::StaticPage) }
    it { is_expected.to be_able_to(:index, Decidim::StaticPage) }
    it { is_expected.to be_able_to(:new, Decidim::StaticPage) }
    it { is_expected.to be_able_to(:read, Decidim::StaticPage) }

    it { is_expected.to be_able_to(:create, Decidim::User) }
    it { is_expected.to be_able_to(:index, Decidim::User) }
    it { is_expected.to be_able_to(:new, Decidim::User) }
    it { is_expected.to be_able_to(:read, Decidim::User) }
    it { is_expected.to be_able_to(:invite, Decidim::User) }

    it { is_expected.to be_able_to(:index, Decidim::UserGroup) }
    it { is_expected.to be_able_to(:verify, Decidim::UserGroup) }

    context "when a page is a default one" do
      let(:page) { build(:static_page, :default) }
      let(:form) { StaticPageForm.new(slug: page.slug) }

      it { is_expected.not_to be_able_to(:update_slug, page) }
      it { is_expected.not_to be_able_to(:update_slug, form) }
      it { is_expected.not_to be_able_to(:destroy, page) }
      it { is_expected.not_to be_able_to(:destroy, form) }
    end

    context "when a page is not default one" do
      let(:page) { build(:static_page) }
      let(:form) { StaticPageForm.new(slug: page.slug) }

      it { is_expected.to be_able_to(:update_slug, page) }
      it { is_expected.to be_able_to(:update_slug, form) }
      it { is_expected.to be_able_to(:destroy, page) }
      it { is_expected.to be_able_to(:destroy, form) }
    end

    context "when the organization is the one they belong to" do
      it { is_expected.to be_able_to(:update, organization) }
      it { is_expected.to be_able_to(:read, organization) }
    end

    context "when the organization is different form the one they belong to" do
      let(:other_organization) { build(:organization) }

      it { is_expected.not_to be_able_to(:update, other_organization) }
      it { is_expected.not_to be_able_to(:read, other_organization) }
    end

    context "when destroying a user" do
      context "when the user is themselves" do
        let(:user_to_destroy) { user }

        it { is_expected.not_to be_able_to(:destroy, user_to_destroy) }
      end

      context "when it is another user" do
        let(:user_to_destroy) { build(:user) }

        it { is_expected.to be_able_to(:destroy, user_to_destroy) }
      end
    end
  end
end
