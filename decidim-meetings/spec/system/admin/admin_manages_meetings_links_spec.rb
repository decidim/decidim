# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/rspec_support/tom_select"

describe "Admin manages meetings" do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, :published, scope:, component: current_component) }

  let!(:other_participatory_space) { create(:participatory_process, organization: current_component.organization) }
  let!(:other_component) { create(:meeting_component, participatory_space: other_participatory_space) }
  let!(:other_meeting) { create(:meeting, :published, component: other_component) }

  include_context "when managing a component as an admin"

  describe "listing meeting links" do
    before do
      create(:meeting_link, meeting: other_meeting, component: current_component)
      visit current_path
    end

    it "shows the meeting links" do
      expect(page).to have_css("tbody tr:first-child", text: Decidim::Meetings::MeetingPresenter.new(other_meeting).title)
      expect(page).to have_css("tbody tr:last-child", text: Decidim::Meetings::MeetingPresenter.new(meeting).title)
    end
  end

  describe "linking a meeting" do
    it "creates a new link" do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within "#accordion-linked-spaces" do
        click_on "Linked spaces"
        tom_select("#add_component_select", option_id: other_meeting.component.id)
        click_on "Assign"
      end

      within ".js-components" do
        expect(page).to have_content(other_meeting.component.manifest.name)
      end

      expect do
        click_on "Update"
      end.to change { meeting.meeting_links.count }.by(1)
    end
  end
end
