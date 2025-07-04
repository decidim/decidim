# frozen_string_literal: true

require "spec_helper"

describe "Organization Areas" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let(:attributes) { attributes_for(:area) }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing areas" do
    let!(:area_type) { create(:area_type, organization: admin.organization) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_on "Settings"
      click_on "Areas"
    end

    it "can create new areas" do
      click_on "Add"

      within ".item__edit-form" do
        fill_in_i18n :area_name, "#area-name-tabs", **attributes[:name].except("machine_translations")

        select area_type.name["en"], from: :area_area_type_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:name]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:name])} area")
    end

    context "with existing areas" do
      let!(:area) { create(:area, organization:, area_type:) }

      before do
        visit current_path
      end

      it "lists all the areas for the organization" do
        within "#areas table" do
          expect(page).to have_content(translated(area.name, locale: :en))
          expect(page).to have_content(translated(area.area_type.name, locale: :en))
        end
      end

      it "can edit them" do
        within "tr", text: translated(area.name) do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end

        within ".item__edit-form" do
          fill_in_i18n :area_name, "#area-name-tabs", **attributes[:name].except("machine_translations")
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content(translated(attributes[:name]))
        end

        visit decidim_admin.root_path
        expect(page).to have_content("updated the #{translated(attributes[:name])} area")
      end

      it "can delete them" do
        click_delete_area

        expect(page).to have_admin_callout("successfully")

        within "#areas" do
          expect(page).to have_no_content(translated(area.name))
        end
      end

      context "when a participatory space associated to a given area exist" do
        let!(:process) { create(:participatory_process, organization: area.organization, area:) }

        it "cannot be deleted" do
          click_delete_area
          expect(area.reload.destroyed?).to be false
          expect(page).to have_admin_callout("This area has dependent spaces")
        end
      end
    end
  end

  private

  def click_delete_area
    within "tr", text: translated(area.name) do
      find("button[data-component='dropdown']").click
      accept_confirm { click_on "Delete" }
    end
  end
end
