# frozen_string_literal: true

require "spec_helper"

describe "Components can be navigated" do
  include_context "with a component"

  let(:manifest_name) { "dummy" }

  describe "navigate to a component" do
    before do
      visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale)
    end

    it "renders the content of the page" do
      within "#menu-bar" do
        expect(page).to have_content("Processes")
        find("a.menu-bar__breadcrumb-desktop__dropdown-trigger", text: translated(participatory_space.title)).sibling("button[data-component='dropdown']").hover
        click_on(translated(component.name))
      end

      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
