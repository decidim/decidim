# frozen_string_literal: true

RSpec.shared_examples "manage child results" do
  it "updates a result" do
    within find("tr", text: translated(child_result.title)) do
      click_link "Edit"
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

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  it "allows the user to preview the result" do
    within find("tr", text: translated(child_result.title)) do
      klass = "action-icon--preview"
      href = resource_locator(child_result).path
      target = "blank"

      expect(page).to have_selector(
        :xpath,
        "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
      )
    end
  end

  it "creates a new child result" do
    click_link "New Result", match: :first

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

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My result")
    end
  end

  describe "deleting a result" do
    before do
      visit current_path
      within ".table-list__actions" do
        click_link "New Result"
      end
    end

    it "deletes a result" do
      within find("tr", text: translated(child_result.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(child_result.title))
      end
    end
  end
end
