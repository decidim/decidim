# frozen_string_literal: true

require "spec_helper"

describe "Admin sorting assemblies" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:old_assembly) { create(:assembly, title: { en: "Old assembly" }, created_at: 3.weeks.ago, organization:) }
  let!(:recent_assembly) { create(:assembly, title: { en: "Recent assembly" }, created_at: 1.day.ago, organization:) }
  let!(:newest_assembly) { create(:assembly, title: { en: "Newest assembly" }, created_at: Time.current, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "when sorting assemblies by their creation" do
    it "sorts by created_at descending by default" do
      within "table thead" do
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Newest assembly")
      expect(titles[1].text).to include("Recent assembly")
      expect(titles[2].text).to include("Old assembly")
    end

    it "sorts by created_at ascending when clicked again" do
      within "table thead" do
        click_link "Created at"
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Old assembly")
      expect(titles[1].text).to include("Recent assembly")
      expect(titles[2].text).to include("Newest assembly")
    end
  end
end
