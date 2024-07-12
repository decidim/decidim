# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies types", type: :system do
  include Decidim::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let(:attributes) { attributes_for(:assemblies_type) }

  describe "Managing assemblies types" do
    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_assemblies.assemblies_types_path
    end

    it "can create new assemblies types", versioning: true do
      click_link "New assembly type"

      within ".new_assembly_type" do
        fill_in_i18n :assemblies_type_title, "#assemblies_type-title-tabs", **attributes[:title].except("machine_translations")
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} assembly type")
    end

    context "with existing assemblies types" do
      let!(:assembly_type) { create(:assemblies_type, organization: organization) }

      before do
        visit current_path
      end

      it "lists all the assemblies types for the organization" do
        within "#assembly-types table" do
          expect(page).to have_content(translated(assembly_type.title, locale: :en))
        end
      end

      it "can edit them", versioning: true do
        within find("tr", text: translated(assembly_type.title)) do
          click_link "Edit"
        end

        within ".edit_assembly_type" do
          fill_in_i18n :assemblies_type_title, "#assemblies_type-title-tabs", **attributes[:title].except("machine_translations")
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content(translated(attributes[:title]))
        end

        visit decidim_admin.root_path
        expect(page).to have_content("updated the #{translated(attributes[:title])} assembly type")
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
