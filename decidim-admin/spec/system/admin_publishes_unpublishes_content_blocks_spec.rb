# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes/unpublishes content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when verifying published blocks appear on homepage" do
    let!(:hero_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage, weight: 1, published_at: Time.current) }

    it "shows published content block on the homepage" do
      visit decidim.root_path

      expect(page).to have_css("[id^=hero]")
    end
  end

  context "when verifying unpublished blocks do not appear on homepage" do
    let!(:hero_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage, weight: nil, published_at: nil) }

    it "does not show unpublished content block on the homepage" do
      visit decidim.root_path

      expect(page).not_to have_css("[id^=hero]")
    end
  end
end
