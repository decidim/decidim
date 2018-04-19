# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory spaces", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let(:space) do
    Decidim
      .find_participatory_space_manifest(:assemblies)
      .space_for(organization)
  end
  let(:assemblies_row) { ".card table tbody tr:first-child" }

  it "can list all spaces" do
    visit_spaces_list

    within assemblies_row do
      expect(page).to have_content("Assemblies") & have_content("Inactive")
    end
    within ".card table tbody tr:nth-child(2)" do
      expect(page).to have_content("Consultations") & have_content("Inactive")
    end
    within ".card table tbody tr:last-child" do
      expect(page).to have_content("Processes") & have_content("Inactive")
    end
  end

  context "when activating an inactive space" do
    it "activates the space" do
      visit_spaces_list

      within assemblies_row do
        click_link "Activate"
      end

      expect(page).to have_admin_callout("successfully")

      within assemblies_row do
        expect(page).to have_content("Assemblies") & have_content("Active")
      end
    end
  end

  context "when deactivating an active space" do
    it "activates the space" do
      space.activate!
      visit_spaces_list

      within assemblies_row do
        click_link "Deactivate"
      end

      expect(page).to have_admin_callout("successfully")

      within assemblies_row do
        expect(page).to have_content("Assemblies") & have_content("Inactive")
      end
    end
  end

  context "when publishing an active space" do
    it "activates the space" do
      space.activate!
      visit_spaces_list

      within assemblies_row do
        click_link "Publish"
      end

      expect(page).to have_admin_callout("successfully")

      within assemblies_row do
        expect(page).to have_content("Assemblies") & have_content("Published")
      end
    end
  end

  context "when unpublishing an active space" do
    it "activates the space" do
      space.activate!
      space.publish!

      visit_spaces_list

      within assemblies_row do
        click_link "Unpublish"
      end

      expect(page).to have_admin_callout("successfully")

      within assemblies_row do
        expect(page).to have_content("Assemblies") & have_content("Active")
      end
    end
  end

  def visit_spaces_list
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Settings"
    click_link "Participatory spaces"
  end
end
