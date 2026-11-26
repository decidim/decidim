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
      expect(page).to have_text(translated(registration_type.title))
    end
  end

  context "when the registration type has registrations and meeting links" do
    let!(:conference_registration) do
      create(:conference_registration, conference:, registration_type:, user: create(:user, :confirmed, organization:))
    end
    let!(:conference_meeting_registration_type) do
      create(:conference_meeting_registration_type, registration_type:)
    end

    before do
      visit current_path
    end

    it "shows the counters and hides the edit and destroy actions" do
      within "#registration_types tr", text: translated(registration_type.title) do
        expect(page).to have_css("td[data-label='Conference meetings']", text: "1")
        expect(page).to have_css("td[data-label='Registrations count']", text: "1")

        find("button[data-controller='dropdown']").click
        expect(page).to have_no_link("Edit")
        expect(page).to have_no_link("Delete")
      end
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

      expect(page).to have_callout("Conference registration type successfully added.")
      expect(page).to have_current_path decidim_admin_conferences.conference_registration_types_path(conference)

      within "#registration_types table" do
        expect(page).to have_text(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_text("created the #{translated(attributes[:title])} registration type")
    end

    it "updates a conference registration types" do
      within "#registration_types tr", text: translated(registration_type.title) do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end

      within ".edit_registration_type" do
        fill_in_i18n(:conference_registration_type_title, "#conference_registration_type-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:conference_registration_type_description, "#conference_registration_type-description-tabs", **attributes[:description].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_callout("Conference registration type successfully updated.")
      expect(page).to have_current_path decidim_admin_conferences.conference_registration_types_path(conference)

      within "#registration_types table" do
        expect(page).to have_text(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_text("updated the #{translated(registration_type.title)} registration type")
    end

    it "deletes the conference registration type" do
      within "#registration_types tr", text: translated(registration_type.title) do
        find("button[data-controller='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_callout("Conference registration type successfully removed.")

      within "#registration_types table" do
        expect(page).to have_no_text(translated(registration_type.title))
      end
    end
  end
end
