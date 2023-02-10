# frozen_string_literal: true

require "spec_helper"

describe "Meeting agenda", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }
  let!(:agenda) { create(:agenda, :with_agenda_items, meeting:, visible:) }
  let(:visible) { true }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when meeting agenda is not visible" do
    let(:visible) { false }

    it "the section agenda is not visible" do
      visit_meeting

      expect(page).not_to have_css("[data-meeting-agenda]")
    end
  end

  context "when meeting agenda is visible" do
    it "shows the agenda section" do
      visit_meeting

      expect(page).to have_css("[data-meeting-agenda]")

      within "[data-meeting-agenda]" do
        expect(page).to have_i18n_content(agenda.title)
        expect(page).to have_css("h3", count: agenda.agenda_items.first_class.count)
      end
    end
  end
end
