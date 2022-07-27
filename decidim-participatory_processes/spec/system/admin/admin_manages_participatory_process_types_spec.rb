# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process types", type: :system do
  include_context "when admin administrating a participatory process"

  let!(:participatory_processes) do
    create_list(:participatory_process, 3, organization:)
  end

  describe "Managing participatory process types" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_process_types_path
    end

    it "can create new participatory process types" do
      click_link "New process type"

      within ".new_participatory_process_type" do
        fill_in_i18n(
          :participatory_process_type_title,
          "#participatory_process_type-title-tabs",
          en: "My participatory process type",
          es: "Mi tipo de proceso participativo",
          ca: "El meu tipus de procés participatiu "
        )
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My participatory process type")
      end
    end

    context "with existing participatory process types" do
      let!(:participatory_process_type) { create(:participatory_process_type, organization:) }

      before do
        visit current_path
      end

      it "lists all the participatory process types for the organization" do
        within "#participatory-process-types table" do
          expect(page).to have_content(translated(participatory_process_type.title, locale: :en))
        end
      end

      it "can edit them" do
        within find("tr", text: translated(participatory_process_type.title)) do
          click_link "Edit"
        end

        within ".edit_participatory_process_type" do
          fill_in_i18n(
            :participatory_process_type_title,
            "#participatory_process_type-title-tabs",
            en: "Another participatory process type",
            es: "Otro tipo de proceso participativo",
            ca: "Un altre tipus de procés participatiu"
          )
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("Another participatory process type")
        end
      end

      it "can delete them" do
        click_delete_participatory_process_type

        expect(page).to have_admin_callout("successfully")

        within ".card-section" do
          expect(page).to have_no_content(translated(participatory_process_type.title))
        end
      end
    end
  end

  private

  def click_delete_participatory_process_type
    within find("tr", text: translated(participatory_process_type.title)) do
      accept_confirm { click_link "Delete" }
    end
  end
end
