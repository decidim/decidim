# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe Abilities::AdminAbility do
    subject { described_class.new(user, {}) }

    let(:user) { build(:user, :admin) }

    context "when the user is not an admin" do
      let(:user) { build(:user) }

      it "doesn't have any permission" do
        expect(subject.permissions[:can]).to be_empty
        expect(subject.permissions[:cannot]).to be_empty
      end
    end

    it { is_expected.to be_able_to(:manage, Decidim::Moderation) }
    it { is_expected.to be_able_to(:manage, Decidim::Attachment) }
    it { is_expected.to be_able_to(:manage, Decidim::Scope) }
    it { is_expected.to be_able_to(:manage, :admin_users) }
    it { is_expected.to be_able_to(:manage, :managed_users) }

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
      let(:organization) { user.organization }

      it { is_expected.to be_able_to(:update, organization) }
      it { is_expected.to be_able_to(:read, organization) }
    end

    context "when the organization is different form the one they belong to" do
      let(:organization) { build(:organization) }

      it { is_expected.not_to be_able_to(:update, organization) }
      it { is_expected.not_to be_able_to(:read, organization) }
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
