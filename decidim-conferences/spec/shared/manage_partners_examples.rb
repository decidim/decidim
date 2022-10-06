# frozen_string_literal: true

shared_examples "manage partners examples" do
  let!(:conference_partner) { create(:partner, conference:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_link "Partners"
  end

  it "shows conference partners list" do
    within "#partners table" do
      expect(page).to have_content(conference_partner.name)
    end
  end

  describe "when managing other conference partners" do
    before do
      visit current_path
    end

    it "updates a conference partners" do
      within find("#partners tr", text: conference_partner.name) do
        click_link "Edit"
      end

      within ".edit_partner" do
        fill_in(
          :conference_partner_name,
          with: "Partner name"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_partners_path(conference)

      within "#partners table" do
        expect(page).to have_content("Partner name")
      end
    end

    it "deletes the conference partner" do
      within find("#partners tr", text: conference_partner.name) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      expect(page).to have_admin_callout("successfully")

      within "#partners table" do
        expect(page).to have_no_content(conference_partner.name)
      end
    end
  end
end
