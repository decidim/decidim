# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debate) { create(:debate, component: component) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__link"
  end

  context "when shows the debate component" do
    it "shows the debate title" do
      expect(page).to have_content debate.title[I18n.locale.to_s]
    end

    it "shows the back button" do
      expect(page).to have_link(href: "#{main_component_path(component)}debates")
    end
  end

  context "when clicking the back button" do
    before do
      visit_component
      click_link(href: "#{main_component_path(component)}debates")
    end

    it "redirect the user to index debates" do
      expect(page).to have_current_path("#{main_component_path(component)}debates")
    end
  end
end
