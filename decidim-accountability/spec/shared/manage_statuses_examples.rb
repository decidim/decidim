# frozen_string_literal: true

RSpec.shared_examples "manage statuses" do
  it "updates a status" do
    within find("tr", text: status.key) do
      find("a.action-icon--edit").click
    end

    within ".edit_status" do
      fill_in_i18n(
        :status_name,
        "#status-name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new name")
    end
  end

  it "creates a new status" do
    click_link "New Status"

    within ".new_status" do
      fill_in :status_key, with: "status_key_1"

      fill_in_i18n(
        :status_name,
        "#status-name-tabs",
        en: "A longer name",
        es: "Nombre más larga",
        ca: "Nom més llarga"
      )

      fill_in_i18n(
        :status_description,
        "#status-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :status_progress, with: 75

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("status_key_1")
      expect(page).to have_content("A longer name")
    end
  end

  context "deleting a result" do
    let!(:status2) { create(:status, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a status" do
      within find("tr", text: status2.key) do
        find("a.action-icon--remove").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(status2.key)
      end
    end
  end
end
