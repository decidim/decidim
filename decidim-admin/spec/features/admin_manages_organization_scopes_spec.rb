# frozen_string_literal: true

require "spec_helper"

describe "Organization scopes", type: :feature do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing scopes" do
    let!(:scope_type) { create(:scope_type, organization: admin.organization) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Settings"
      click_link "Scopes"
    end

    it "can create new scopes" do
      click_link "Add"

      within ".new_scope" do
        fill_in_i18n :scope_name, "#scope-name-tabs", en: "My nice district",
                                                      es: "Mi lindo distrito",
                                                      ca: "El meu bonic barri"
        fill_in "Code", with: "MY-DISTRICT"
        select scope_type.name["en"], from: :scope_scope_type_id

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My nice district")
      end
    end

    context "with existing scopes" do
      let!(:scope) { create(:scope, organization: organization) }

      before do
        visit current_path
      end

      it "can edit them" do
        within find("tr", text: translated(scope.name)) do
          page.find("a.action-icon.action-icon--edit").click
        end

        within ".edit_scope" do
          fill_in_i18n :scope_name, "#scope-name-tabs", en: "Another district",
                                                        es: "Otro distrito",
                                                        ca: "Un altre districte"
          find("*[type=submit]").click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("Another district")
        end
      end

      it "can destroy them" do
        within find("tr", text: translated(scope.name)) do
          accept_confirm { page.find("a.action-icon.action-icon--remove").click }
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within ".card-section" do
          expect(page).to have_no_content(translated(scope.name))
        end
      end

      it "can create a new subcope" do
        within find("tr", text: translated(scope.name)) do
          page.find("td:first-child a").click
        end

        click_link "Add"

        within ".new_scope" do
          fill_in_i18n :scope_name, "#scope-name-tabs", en: "My nice subdistrict",
                                                        es: "Mi lindo subdistrito",
                                                        ca: "El meu bonic subbarri"
          fill_in "Code", with: "MY-SUBDISTRICT"
          select scope_type.name["en"], from: :scope_scope_type_id

          find("*[type=submit]").click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("My nice subdistrict")
        end
      end
    end
  end
end
