# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives types", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:initiatives_type) { create(:initiatives_type, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_types_path
  end

  context "when accessing initiative types list" do
    it "shows the initiative type data" do
      expect(page).to have_i18n_content(initiatives_type.title)
    end
  end

  context "when creating an initiative type" do
    it "creates the initiative type" do
      click_link "New initiative type"

      fill_in_i18n(
        :initiatives_type_title,
        "#initiatives_type-title-tabs",
        en: "My initiative type"
      )

      fill_in_i18n_editor(
        :initiatives_type_description,
        "#initiatives_type-description-tabs",
        en: "A longer description"
      )

      select("Online", from: "Signature type")

      dynamically_attach_file(:initiatives_type_banner_image, Decidim::Dev.asset("city2.jpeg"))

      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new initiative type has been successfully created")
      end
    end
  end

  context "when updating an initiative type" do
    it "updates the initiative type" do
      within find("tr", text: translated(initiatives_type.title)) do
        page.find(".action-icon--edit").click
      end

      fill_in_i18n(
        :initiatives_type_title,
        "#initiatives_type-title-tabs",
        en: "My updated initiative type"
      )

      select("Mixed", from: "Signature type")
      check "Enable attachments"
      uncheck "Enable participants to undo their online signatures"
      check "Enable authors to choose the end of signature collection period"
      check "Enable authors to choose the area for their initiative"
      uncheck "Enable comments"

      click_button "Update"

      within ".callout-wrapper" do
        expect(page).to have_content("The initiative type has been successfully updated")
      end
    end
  end

  context "when deleting an initiative type" do
    it "deletes the initiative type" do
      within find("tr", text: translated(initiatives_type.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("The initiative type has been successfully removed")
      end
    end
  end
end
