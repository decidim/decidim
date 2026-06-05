# frozen_string_literal: true

require "spec_helper"

describe "Global meetings directory", :slow do
  let(:organization) { create(:organization) }
  let!(:participatory_process1) { create(:participatory_process, organization:) }
  let!(:meeting_component1) { create(:meeting_component, participatory_space: participatory_process1) }
  let!(:participatory_process2) { create(:participatory_process, organization:) }
  let!(:meeting_component2) { create(:meeting_component, participatory_space: participatory_process2) }

  let!(:meeting1) do
    create(:meeting, :published, :upcoming, title: { en: "First meeting" }, component: meeting_component1)
  end
  let!(:meeting2) do
    create(:meeting, :published, :upcoming, title: { en: "Second meeting" }, component: meeting_component1)
  end
  let!(:meeting3) do
    create(:meeting, :published, :upcoming, title: { en: "Third meeting" }, component: meeting_component2)
  end

  before do
    switch_to_host(organization.host)
    visit Decidim::Meetings::DirectoryEngine.routes.url_helpers.root_path
  end

  it "shows all meetings from all participatory spaces" do
    within ".layout-2col__main" do
      expect(page).to have_text("First meeting")
      expect(page).to have_text("Second meeting")
      expect(page).to have_text("Third meeting")
    end
  end

  it "shows the participatory space name for each meeting in the main list" do
    within ".layout-2col__main" do
      expect(page).to have_text translated(participatory_process1.title)
      expect(page.html).to include decidim_escape_translated(participatory_process1.title).gsub("&quot;", "\"")
      expect(page).to have_text translated(participatory_process2.title)
      expect(page.html).to include decidim_escape_translated(participatory_process2.title).gsub("&quot;", "\"")
    end
  end
end
