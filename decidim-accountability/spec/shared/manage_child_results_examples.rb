# frozen_string_literal: true

RSpec.shared_examples "manage child results" do
  it "updates a result" do
    within "tr", text: translated(child_result.title) do
      find("button[data-component='dropdown']").click
      click_on "Edit"
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
    within "tr", text: translated(child_result.title) do
      find("button[data-component='dropdown']").click
      preview_window = window_opened_by { click_on "Preview" }

      within_window preview_window do
        expect(page).to have_content translated(result.title)
        expect(page).to have_content "Progress"
      end
    end
  end

  it "creates a new child result" do
    click_on "New result"

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
      expect(page).not_to have_css(".button", text: "New result"), "results grandchildren creation is disallowed"
    end
  end

  describe "soft delete a result" do
    before do
      visit current_path
      within "tr", text: translated(result.title) do
        find("button[data-component='dropdown']").click
        click_on "New result"
      end
    end

    it "moves to the trash a result" do
      within "tr", text: translated(child_result.title) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Soft delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(child_result.title))
      end
    end
  end
end
