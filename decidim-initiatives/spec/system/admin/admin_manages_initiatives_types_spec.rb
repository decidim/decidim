# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives types" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:initiatives_type) { create(:initiatives_type, organization:) }
  let(:attributes) { attributes_for(:initiatives_type) }

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
      click_on "New initiative type"

      fill_in_i18n(
        :initiatives_type_title,
        "#initiatives_type-title-tabs",
        **attributes[:title].except("machine_translations")
      )

      fill_in_i18n_editor(
        :initiatives_type_description,
        "#initiatives_type-description-tabs",
        **attributes[:description].except("machine_translations")
      )

      select("Online", from: "Signature type")

      dynamically_attach_file(:initiatives_type_banner_image, Decidim::Dev.asset("city2.jpeg"))

      click_on "Create"

      expect(page).to have_admin_callout("A new initiative type has been successfully created")

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} initiatives type")
    end
  end

  context "when updating an initiative type" do
    it "updates the initiative type" do
      within "tr", text: translated(initiatives_type.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end

      fill_in_i18n(
        :initiatives_type_title,
        "#initiatives_type-title-tabs",
        **attributes[:title].except("machine_translations")
      )
      fill_in_i18n_editor(
        :initiatives_type_description,
        "#initiatives_type-description-tabs",
        **attributes[:description].except("machine_translations")
      )

      select("Mixed", from: "Signature type")
      check "Enable attachments"
      uncheck "Enable participants to undo their online signatures"
      check "Enable authors to choose the end of signature collection period"
      check "Enable authors to choose the area for their initiative"
      uncheck "Enable comments"

      click_on "Update"

      expect(page).to have_admin_callout("The initiative type has been successfully updated")

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} initiatives type")
    end
  end

  context "when deleting an initiative type" do
    it "deletes the initiative type" do
      within "tr", text: translated(initiatives_type.title) do
        find("button[data-component='dropdown']").click
        accept_confirm do
          click_on "Delete"
        end
      end

      expect(page).to have_admin_callout("The initiative type has been successfully removed")
    end
  end
end
