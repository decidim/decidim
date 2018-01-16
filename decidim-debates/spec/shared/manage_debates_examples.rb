# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage debates" do
  it "updates a debate" do
    within find("tr", text: translated(debate.title)) do
      page.find('.action-icon--edit').click
    end

    within ".edit_debate" do
      fill_in_i18n(
        :debate_title,
        "#debate-title-tabs",
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

  context "previewing debates" do
    it "links the debate correctly" do
      link = find("a", text: translated(debate.title))
      expect(link[:href]).to include(resource_locator(debate).path)
    end

    it "shows a preview of the debate" do
      visit resource_locator(debate).path
      expect(page).to have_content(translated(debate.title))
    end
  end

  it "creates a new debate" do
    within ".card-title" do
      page.find('.button.button--title').click
    end

    within ".new_debate" do
      fill_in_i18n(
        :debate_title,
        "#debate-title-tabs",
        en: "My debate",
        es: "Mi debate",
        ca: "El meu debat"
      )
      fill_in_i18n_editor(
        :debate_description,
        "#debate-description-tabs",
        en: "Long description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in_i18n_editor(
        :debate_instructions,
        "#debate-instructions-tabs",
        en: "Long instructions",
        es: "Instrucciones más largas",
        ca: "Instruccions més llargues"
      )
    end

    page.execute_script("$('#datetime_field_debate_start_time').focus()")
    page.find('.datepicker-dropdown .day', text: '12').click
    page.find('.datepicker-dropdown .hour', text: '10:00').click
    page.find('.datepicker-dropdown .minute', text: '10:50').click

    page.execute_script("$('#datetime_field_debate_end_time').focus()")
    page.find('.datepicker-dropdown .day', text: '12').click
    page.find('.datepicker-dropdown .hour', text: '12:00').click
    page.find('.datepicker-dropdown .minute', text: '12:50').click

    within ".new_debate" do
      select translated(category.name), from: :debate_decidim_category_id

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My debate")
    end
  end

  context "deleting a debate" do
    let!(:debate2) { create(:debate, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a debate" do
      within find("tr", text: translated(debate2.title)) do
        accept_confirm do
          page.find('.action-icon--remove').click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(debate2.title))
      end
    end
  end
end
