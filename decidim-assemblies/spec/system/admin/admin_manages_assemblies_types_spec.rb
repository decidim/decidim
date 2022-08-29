# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", type: :system do
  include Decidim::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  describe "Managing assemblies types" do
    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_assemblies.assemblies_types_path
    end

    it "can create new assemblies types" do
      click_link "New assembly type"

      within ".new_assembly_type" do
        fill_in_i18n :assemblies_type_title, "#assemblies_type-title-tabs", en: "My assembly type",
                                                                            es: "Mi assembly type",
                                                                            ca: "La meva assembly type"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My assembly type")
      end
    end

    context "with existing assemblies types" do
      let!(:assembly_type) { create(:assemblies_type, organization:) }

      before do
        visit current_path
      end

      it "lists all the assemblies types for the organization" do
        within "#assembly-types table" do
          expect(page).to have_content(translated(assembly_type.title, locale: :en))
        end
      end

      it "can edit them" do
        within find("tr", text: translated(assembly_type.title)) do
          click_link "Edit"
        end

        within ".edit_assembly_type" do
          fill_in_i18n :assemblies_type_title, "#assemblies_type-title-tabs", en: "Another assembly type",
                                                                              es: "Otra assembly type",
                                                                              ca: "Una altra assembly type"
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("Another assembly type")
        end
      end

      it "can delete them" do
        click_delete_assembly_type

        expect(page).to have_admin_callout("successfully")

        within ".card-section" do
          expect(page).to have_no_content(translated(assembly_type.title))
        end
      end
    end
  end

  private

  def click_delete_assembly_type
    within find("tr", text: translated(assembly_type.title)) do
      accept_confirm { click_link "Delete" }
    end
  end
end
