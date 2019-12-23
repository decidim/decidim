# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposal) { create(:proposal, component: component) }

  before do
    visit_component
    click_link proposal.title[I18n.locale.to_s], class: "card__link"
  end

  context "when shows the proposal component" do
    it "shows the proposal title" do
      expect(page).to have_content proposal.title[I18n.locale.to_s]
    end

    it "shows the back button" do
      expect(page).to have_link(href: "#{main_component_path(component)}proposals")
    end
  end

  context "when clicking the back button" do
    before do
      visit_component
      click_link(href: "#{main_component_path(component)}proposals")
    end

    it "redirect the user to index proposals" do
      expect(page).to have_current_path("#{main_component_path(component)}proposals")
    end
  end
end
