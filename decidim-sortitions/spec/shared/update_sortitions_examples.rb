# frozen_string_literal: true

shared_examples "update sortitions" do
  describe "update sortition data" do
    let!(:sortition) { create(:sortition, component: current_component) }

    before do
      visit_component_admin
      click_link "Edit"
    end

    it "requires title" do
      within "form" do
        expect(page).to have_content(/Title/i)
      end
    end

    it "requires additional information" do
      within "form" do
        expect(page).to have_content(/Sortition information/i)
      end
    end

    context "when updates a sortition" do
      it "Redirects to sortitions view" do
        within ".edit_sortition" do
          fill_in_i18n_editor(
            :sortition_additional_info,
            "#sortition-additional_info-tabs",
            en: "Additional info",
            es: "Información adicional",
            ca: "Informació adicional"
          )

          fill_in_i18n(
            :sortition_title,
            "#sortition-title-tabs",
            en: "Title",
            es: "Título",
            ca: "Títol"
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
