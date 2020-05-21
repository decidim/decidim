# frozen_string_literal: true

require "spec_helper"

describe "InitiativeTypesController", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when accessing initiative types list" do
    let!(:initiative_type) { create :initiatives_type, organization: organization }

    it "Shows the initiative type data" do
      visit decidim_admin_initiatives.initiatives_types_path
      expect(page).to have_i18n_content(initiative_type.title)
    end
  end

  context "when creating an initiative type" do
    it "creates the initiative type" do
      visit decidim_admin_initiatives.initiatives_types_path
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

      attach_file "Banner image", Decidim::Dev.asset("city2.jpeg")

      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new initiative type has been successfully created")
      end
    end
  end

  context "when updating an initiative type" do
    let(:initiatives_type) { create(:initiatives_type, :online_signature_enabled, :attachments_disabled, :undo_online_signatures_enabled, :custom_signature_end_date_disabled, organization: organization) }

    it "Updates the initiative type" do
      visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)

      fill_in_i18n(
        :initiatives_type_title,
        "#initiatives_type-title-tabs",
        en: "My updated initiative type"
      )

      select("In-person", from: "Signature type")
      check "Enable attachments"
      uncheck "Enable participants to undo their online signatures"
      check "Enable authors to choose the end of signature collection period"

      click_button "Update"

      within ".callout-wrapper" do
        expect(page).to have_content("The initiative type has been successfully updated")
      end
    end
  end

  context "when deleting an initiative type" do
    let(:initiatives_type) { create :initiatives_type, organization: organization }

    it "Deletes the initiative type" do
      visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)

      accept_confirm { click_link "Delete" }

      within ".callout-wrapper" do
        expect(page).to have_content("The initiative type has been successfully removed")
      end
    end
  end
end
