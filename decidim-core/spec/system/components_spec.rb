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
      within ".process-nav" do
        click_link component.name[I18n.locale.to_s]
      end

      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
