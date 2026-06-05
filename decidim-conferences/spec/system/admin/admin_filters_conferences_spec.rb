# frozen_string_literal: true

require "spec_helper"

describe "Admin sorting conferences" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:old_conference) { create(:conference, title: { en: "Old conference" }, created_at: 3.weeks.ago, organization:) }
  let!(:recent_conference) { create(:conference, title: { en: "Recent conference" }, created_at: 1.day.ago, organization:) }
  let!(:newest_conference) { create(:conference, title: { en: "Newest conference" }, created_at: Time.current, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path
  end

  context "when sorting conferences by their creation" do
    it "sorts by created_at descending by default" do
      within "table thead" do
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Newest conference")
      expect(titles[1].text).to include("Recent conference")
      expect(titles[2].text).to include("Old conference")
    end

    it "sorts by created_at ascending when clicked again" do
      within "table thead" do
        click_link "Created at"
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Old conference")
      expect(titles[1].text).to include("Recent conference")
      expect(titles[2].text).to include("Newest conference")
    end
  end
end
