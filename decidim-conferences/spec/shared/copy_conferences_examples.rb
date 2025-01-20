# frozen_string_literal: true

shared_examples "copy conferences" do
  let!(:conference) { create(:conference, organization:) }
  let!(:component) { create(:component, manifest_name: :dummy, participatory_space: conference) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path
  end

  context "without any context" do
    it "copies the conference with the basic fields" do
      click_on "Duplicate", match: :first

      within ".copy_conference" do
        fill_in_i18n(
          :conference_title,
          "#conference-title-tabs",
          en: "Copy conference",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :conference_slug, with: "pp-copy"
        click_on "Copy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Copy conference")
      expect(page).to have_content("Unpublished")
    end
  end

  context "with context" do
    before do
      click_on "Duplicate", match: :first

      within ".copy_conference" do
        fill_in_i18n(
          :conference_title,
          "#conference-title-tabs",
          en: "Copy conference",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :conference_slug, with: "conference-copy"
      end
    end

    it "copies the conference with components" do
      page.check("conference[copy_components]")
      click_on "Copy"

      expect(page).to have_content("successfully")

      within "tr", text: "Copy conference" do
        click_on "Configure"
      end
      within_admin_sidebar_menu do
        click_on "Components"
      end

      within ".table-list" do
        conference.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end
    end
  end
end
