# frozen_string_literal: true

RSpec.shared_examples "manage child results" do
  it "updates a result" do
    within find("tr", text: translated(child_result.title)) do
      find("a.action-icon--edit").click
    end

    within ".edit_result" do
      fill_in_i18n(
        :result_title,
        "#result-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "previewing results", driver: :poltergeist do
    it "allows the user to preview the result" do
      within find("tr", text: translated(child_result.title)) do
        @new_window = window_opened_by { find("a.action-icon--preview").click }
      end

      within_window @new_window do
        expect(current_path).to eq(resource_locator(child_result).path)
        expect(page).to have_content(translated(child_result.title))
      end
    end
  end

  it "creates a new child result" do
    click_link "New Result"

    within ".new_result" do
      fill_in_i18n(
        :result_title,
        "#result-title-tabs",
        en: "My result",
        es: "Mi result",
        ca: "El meu result"
      )
      fill_in_i18n_editor(
        :result_description,
        "#result-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      select "Ongoing", from: :result_decidim_accountability_status_id
      fill_in :result_progress, with: 89

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My result")
    end
  end

  context "deleting a result" do
    before do
      visit current_path
      click_link translated(result.title)
    end

    it "deletes a result" do
      within find("tr", text: translated(child_result.title)) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(child_result.title))
      end
    end
  end
end
