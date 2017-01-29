# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage results" do
  it "updates a result" do
    within find("tr", text: translated(result.title)) do
      click_link "Edit"
    end

    within ".edit_result" do
      fill_in_i18n(
        :result_title,
        "#title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "previewing results" do
    it "allows the user to preview the result" do
      new_window = window_opened_by { click_link translated(result.title) }

      within_window new_window do
        expect(current_path).to eq decidim_results.result_path(id: result.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(result.title))
      end
    end
  end

  it "creates a new result" do
    find(".actions .new").click

    within ".new_result" do
      fill_in_i18n(
        :result_title,
        "#title-tabs",
        en: "My result",
        es: "Mi result",
        ca: "El meu result"
      )
      fill_in_i18n_editor(
        :result_short_description,
        "#short_description-tabs",
        en: "Short description",
        es: "Descripción corta",
        ca: "Descripció curta"
      )
      fill_in_i18n_editor(
        :result_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      select scope.name, from: :result_decidim_scope_id
      select translated(category.name), from: :result_decidim_category_id

      find("*[type=submit]").click
    end

    within ".flash" do
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
        click_link "Delete"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(result2.title))
      end
    end
  end
end
