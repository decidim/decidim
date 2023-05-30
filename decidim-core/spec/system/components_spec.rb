# frozen_string_literal: true

require "spec_helper"

describe "Components can be navigated", type: :system do
  include_context "with a component"

  let(:manifest_name) { "dummy" }

  describe "navigate to a component" do
    before do
      visit decidim_participatory_processes.participatory_process_path(participatory_process)
    end

    it "renders the content of the page" do
      skip_unless_redesign_enabled "This test works with the redesigned navigation layout"

      within "#menu-bar" do
        expect(page).to have_content("Processes")
        find("#secondary-dropdown-summary", text: translated(participatory_space.title)).click
        click_link(translated(component.name))
      end

      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
