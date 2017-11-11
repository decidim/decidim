# frozen_string_literal: true

shared_examples "manage results" do
  include_context "admin"
  include_context "feature admin"

  it "updates a result" do
    within find("tr", text: translated(result.title)) do
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

  context "previewing results" do
    it "allows the user to preview the result" do
      within find("tr", text: translated(result.title)) do
        klass = "action-icon--preview"
        href = resource_locator(result).path
        target = "blank"

        expect(page).to have_selector(
          :xpath,
          "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
        )
      end
    end
  end

  it "creates a new result" do
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

      select2 translated(scope.name), xpath: '//select[@id="result_decidim_scope_id"]/..', search: true

      select translated(category.name), from: :result_decidim_category_id

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
    let!(:result2) { create(:result, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a result" do
      within find("tr", text: translated(result2.title)) do
        find("a.action-icon--remove").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(result2.title))
      end
    end
  end
end
