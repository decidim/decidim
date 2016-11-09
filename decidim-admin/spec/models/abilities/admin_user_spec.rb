# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::Abilities::AdminUser do
  let(:user) { build(:user, :admin) }

  subject { described_class.new(user) }

  context "when the user is not an admin" do
    let(:user) { build(:user) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcess) }
  it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcessStep) }

  it { is_expected.to be_able_to(:create, Decidim::Page) }
  it { is_expected.to be_able_to(:update, Decidim::Page) }
  it { is_expected.to be_able_to(:index, Decidim::Page) }
  it { is_expected.to be_able_to(:new, Decidim::Page) }
  it { is_expected.to be_able_to(:read, Decidim::Page) }

  context "when a page is a default one" do
    let(:page) { build(:page, :default) }
    let(:form) { Decidim::Admin::PageForm.new(slug: page.slug) }

    it { is_expected.to_not be_able_to(:update_slug, page) }
    it { is_expected.to_not be_able_to(:update_slug, form) }
    it { is_expected.to_not be_able_to(:destroy, page) }
    it { is_expected.to_not be_able_to(:destroy, form) }
  end

  context "when a page is not default one" do
    let(:page) { build(:page) }
    let(:form) { Decidim::Admin::PageForm.new(slug: page.slug) }

    it { is_expected.to be_able_to(:update_slug, page) }
    it { is_expected.to be_able_to(:update_slug, form) }
    it { is_expected.to be_able_to(:destroy, page) }
    it { is_expected.to be_able_to(:destroy, form) }
  end
end
