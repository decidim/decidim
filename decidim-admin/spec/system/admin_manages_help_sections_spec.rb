# frozen_string_literal: true

require "spec_helper"

describe "Admin manages help sections", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.help_sections_path
  end

  describe "update help sections" do
    it "updates the values from the form" do
      fill_in_i18n_editor :help_sections_sections_participatory_processes_content,
                          "#sections_participatory_processes_content",
                          en: "<p>Well hello!</p>"

      click_button "Save"

      within ".callout.success" do
        expect(page).to have_content("successfully")
      end

      within "#sections_participatory_processes_content-content-panel-0" do
        expect(page).to have_content("Well hello!")
      end

      help_content = Decidim::ContextualHelpSection.find_content(organization, :participatory_processes)
      expect(help_content).to include("en" => "<p>Well hello!</p>")
    end

    it "destroys the section when it is empty" do
      clear_i18n_editor :help_sections_sections_participatory_processes_content, "#sections_participatory_processes_content", [:en]

      click_button "Save"

      within ".callout.success" do
        expect(page).to have_content("successfully")
      end

      within "#sections_participatory_processes_content-content-panel-0" do
        expect(page).to have_content("")
      end

      help_content = Decidim::ContextualHelpSection.find_content(organization, :participatory_processes)
      expect(help_content).to eq({})
    end
  end
end
