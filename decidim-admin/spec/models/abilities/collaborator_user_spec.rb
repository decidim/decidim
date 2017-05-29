# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Abilities::CollaboratorUser do
  let(:user) { build(:user, :collaborator) }

  subject { described_class.new(user, {}) }

  context "when the user is not a collaborator" do
    let(:user) { build(:user) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:preview, Decidim::ParticipatoryProcess) }

  context "when a page is a default one" do
    let(:page) { build(:static_page, :default) }
    let(:form) { Decidim::Admin::StaticPageForm.new(slug: page.slug) }

    it { is_expected.not_to be_able_to(:update_slug, page) }
    it { is_expected.not_to be_able_to(:update_slug, form) }
    it { is_expected.not_to be_able_to(:destroy, page) }
    it { is_expected.not_to be_able_to(:destroy, form) }
  end

  context "when a page is not default one" do
    let(:page) { build(:static_page) }
    let(:form) { Decidim::Admin::StaticPageForm.new(slug: page.slug) }

    it { is_expected.not_to be_able_to(:update_slug, page) }
    it { is_expected.not_to be_able_to(:update_slug, form) }
    it { is_expected.not_to be_able_to(:destroy, page) }
    it { is_expected.not_to be_able_to(:destroy, form) }
  end

  context "when the organization is the one they belong to" do
    let(:organization) { user.organization }

    it { is_expected.not_to be_able_to(:update, organization) }
    it { is_expected.not_to be_able_to(:read, organization) }
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

      it { is_expected.not_to be_able_to(:destroy, user_to_destroy) }
    end
  end
end
