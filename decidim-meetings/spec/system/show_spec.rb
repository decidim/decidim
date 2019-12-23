# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, component: component) }

  before do
    visit_component
    click_link meeting.title[I18n.locale.to_s], class: "card__link"
  end

  context "when shows the meeting component" do
    it "shows the meeting title" do
      expect(page).to have_content meeting.title[I18n.locale.to_s]
    end

    it "shows the back button" do
      expect(page).to have_link(href: "#{main_component_path(component)}meetings")
    end
  end

  context "when clicking the back button" do
    before do
      visit_component
      click_link(href: "#{main_component_path(component)}meetings")
    end

    it "redirect the user to index meetings" do
      expect(page).to have_current_path("#{main_component_path(component)}meetings")
    end
  end
end
