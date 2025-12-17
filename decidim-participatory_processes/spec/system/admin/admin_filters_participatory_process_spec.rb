# frozen_string_literal: true

require "spec_helper"

describe "Admin sorting participatory processes" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:old_process) { create(:participatory_process, title: { en: "Old Process" }, created_at: 3.weeks.ago, organization:) }
  let!(:recent_process) { create(:participatory_process, title: { en: "Recent Process" }, created_at: 1.day.ago, organization:) }
  let!(:newest_process) { create(:participatory_process, title: { en: "Newest Process" }, created_at: Time.current, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "when sorting processes by their creation" do
    it "sorts by created_at descending by default" do
      within "table thead" do
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Newest Process")
      expect(titles[1].text).to include("Recent Process")
      expect(titles[2].text).to include("Old Process")
    end

    it "sorts by created_at ascending when clicked again" do
      within "table thead" do
        click_link "Created at"
        click_link "Created at"
      end

      titles = page.all("table tbody tr td:first-child")
      expect(titles[0].text).to include("Old Process")
      expect(titles[1].text).to include("Recent Process")
      expect(titles[2].text).to include("Newest Process")
    end
  end
end
