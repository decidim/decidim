# frozen_string_literal: true

require "spec_helper"

describe "Organization Areas", type: :system do
  include Decidim::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing areas" do
    let!(:area_type) { create(:area_type, organization: admin.organization) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Settings"
      click_link "Areas"
    end

    it "can create new areas" do
      click_link "Add"

      within ".new_area" do
        fill_in_i18n :area_name, "#area-name-tabs", en: "My area",
                                                    es: "Mi area",
                                                    ca: "La meva area"
        select area_type.name["en"], from: :area_area_type_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My area")
      end
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
        within find("tr", text: translated(area.name)) do
          click_link "Edit"
        end

        within ".edit_area" do
          fill_in_i18n :area_name, "#area-name-tabs", en: "Another area",
                                                      es: "Otra area",
                                                      ca: "Una altra area"
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("Another area")
        end
      end

      it "can delete them" do
        click_delete_area

        expect(page).to have_admin_callout("successfully")

        within ".card-section" do
          expect(page).to have_no_content(translated(area.name))
        end
      end

      context "when a participatory space associated to a given area exist" do
        let!(:process) { create(:participatory_process, organization: area.organization, area:) }

        it "can not be deleted" do
          click_delete_area
          expect(area.reload.destroyed?).to be false
          expect(page).to have_admin_callout("This area has dependent spaces")
        end
      end
    end
  end

  private

  def click_delete_area
    within find("tr", text: translated(area.name)) do
      accept_confirm { click_link "Delete" }
    end
  end
end
