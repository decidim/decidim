# frozen_string_literal: true

require "spec_helper"

describe "Admin manages sortitions" do
  let(:manifest_name) { "sortitions" }

  include_context "when managing a component as an admin"

  it_behaves_like "manage sortitions"
  it_behaves_like "cancel sortitions"
  it_behaves_like "update sortitions"
  it_behaves_like "manage taxonomy filters in settings"

  context "when adding a new sortitions module" do
    let(:component_name) { "My super new sortitions component" }

    it "is added" do
      visit current_path
      within_admin_sidebar_menu do
        click_on "Components"
      end
      click_on "Add component"
      click_on "Sortitions"

      fill_in_i18n(
        :component_name,
        "#component-name-tabs",
        en: component_name
      )

      click_on "Add component"

      expect(page).to have_content("Component created successfully")
      expect(page).to have_content(component_name)
    end
  end
end
