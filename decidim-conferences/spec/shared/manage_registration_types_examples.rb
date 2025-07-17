# frozen_string_literal: true

shared_examples "manage registration types examples" do
  let!(:registration_type) { create(:registration_type, conference:) }
  let(:attributes) { attributes_for(:registration_type, conference:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_on "Registration types"
    end
  end

  it "shows conference registration types list" do
    within "#registration_types table" do
      expect(page).to have_content(translated(registration_type.title))
    end
  end

  describe "when managing other conference registration types" do
    before do
      visit current_path
    end

    it "creates a conference registration types", versioning: true do
      click_on "New registration type"

      within ".new_registration_type" do
        fill_in_i18n(:conference_registration_type_title, "#conference_registration_type-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:conference_registration_type_description, "#conference_registration_type-description-tabs", **attributes[:description].except("machine_translations"))

        fill_in(:conference_registration_type_weight, with: 4)

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_registration_types_path(conference)

      within "#registration_types table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} registration type")
    end

    it "updates a conference registration types" do
      within "#registration_types tr", text: translated(registration_type.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_registration_type" do
        fill_in_i18n(:conference_registration_type_title, "#conference_registration_type-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:conference_registration_type_description, "#conference_registration_type-description-tabs", **attributes[:description].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_registration_types_path(conference)

      within "#registration_types table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(registration_type.title)} registration type")
    end

    it "deletes the conference registration type" do
      within "#registration_types tr", text: translated(registration_type.title) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#registration_types table" do
        expect(page).to have_no_content(translated(registration_type.title))
      end
    end
  end
end
