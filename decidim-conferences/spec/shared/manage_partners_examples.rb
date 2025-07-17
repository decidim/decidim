# frozen_string_literal: true

shared_examples "manage partners examples" do
  let!(:conference_partner) { create(:partner, conference:) }
  let!(:attributes) { attributes_for(:partner, conference:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_on "Partners"
    end
  end

  it "shows conference partners list" do
    within "#partners table" do
      expect(page).to have_content(conference_partner.name)
    end
  end

  describe "when managing other conference partners" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    before do
      visit current_path
    end

    it "creates a conference partner", versioning: true do
      click_on "New partner"
      dynamically_attach_file(:conference_partner_logo, image1_path)

      within ".new_partner" do
        fill_in(:conference_partner_name, with: attributes[:name])

        select("Collaborator", from: :conference_partner_partner_type)

        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_partners_path(conference)

      within "#partners table" do
        expect(page).to have_content(attributes[:name])
        expect(page).to have_content("Collaborator")
      end
      visit decidim_admin.root_path
      expect(page).to have_content("created the partner #{attributes[:name]}")
    end

    it "updates a conference partners", versioning: true do
      within "#partners tr", text: conference_partner.name do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_partner" do
        fill_in(:conference_partner_name, with: attributes[:name])

        select(
          "Collaborator",
          from: :conference_partner_partner_type
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_partners_path(conference)

      within "#partners table" do
        expect(page).to have_content(attributes[:name])
        expect(page).to have_content("Collaborator")
      end
      visit decidim_admin.root_path
      expect(page).to have_content("updated the partner #{conference_partner.name}")
    end

    context "when the partner type is already a Collaborator" do
      let!(:conference_partner) { create(:partner, partner_type: "collaborator", conference:) }

      it "returns the correct partner type in the edit" do
        visit decidim_admin_conferences.edit_conference_partner_path(conference, conference_partner)
        within ".edit_partner" do
          expect(page).to have_select(
            :conference_partner_partner_type,
            selected: "Collaborator"
          )
        end
      end
    end

    it "deletes the conference partner" do
      within "#partners tr", text: conference_partner.name do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#partners table" do
        expect(page).to have_no_content(conference_partner.name)
      end
    end
  end
end
