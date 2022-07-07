# frozen_string_literal: true

shared_examples "manage registration types examples" do
  let!(:registration_type) { create(:registration_type, conference: conference) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_link "Registration Types"
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

    it "updates a conference registration types" do
      within find("#registration_types tr", text: translated(registration_type.title)) do
        click_link "Edit"
      end

      within ".edit_registration_type" do
        fill_in_i18n(
          :conference_registration_type_title,
          "#conference_registration_type-title-tabs",
          en: "Registration type title",
          es: "Registration type title es",
          ca: "Registration type title ca"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_registration_types_path(conference)

      within "#registration_types table" do
        expect(page).to have_content("Registration type title")
      end
    end

    it "deletes the conference registration type" do
      within find("#registration_types tr", text: translated(registration_type.title)) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      expect(page).to have_admin_callout("successfully")

      within "#registration_types table" do
        expect(page).to have_no_content(translated(registration_type.title))
      end
    end
  end
end
