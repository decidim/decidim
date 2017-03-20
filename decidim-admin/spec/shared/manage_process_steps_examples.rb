# coding: utf-8
# frozen_string_literal: true
RSpec.shared_examples "manage process steps examples" do
  let(:active) { false }
  let!(:process_step) do
    create(
      :participatory_process_step,
      participatory_process: participatory_process,
      active: active
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Steps"
  end

  it "creates a new participatory_process" do
    find(".card-title a.button").click

    within ".new_participatory_process_step" do
      fill_in_i18n(
        :participatory_process_step_title,
        "#title-tabs",
        en: "My participatory process step",
        es: "Mi fase de proceso participativo",
        ca: "La meva fase de procés participatiu"
      )
      fill_in_i18n_editor(
        :participatory_process_step_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :participatory_process_step_start_date, with: 1.months.ago.to_date
      fill_in :participatory_process_step_end_date, with: 2.months.from_now.to_date

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#steps table" do
      expect(page).to have_content("My participatory process step")
    end
  end

  it "updates a participatory_process_step" do
    within "#steps" do
      within find("tr", text: translated(process_step.title)) do
        page.find('.action-icon--edit').click
      end
    end

    within ".edit_participatory_process_step" do
      fill_in_i18n(
        :participatory_process_step_title,
        "#title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#steps table" do
      expect(page).to have_content("My new title")
      click_link("My new title")
    end
  end

  context "deleting a participatory process step" do
    let!(:process_step2) { create(:participatory_process_step, participatory_process: participatory_process) }

    before do
      visit current_path
    end

    it "deletes a participatory_process_step" do
      within find("tr", text: translated(process_step2.title)) do
        page.find('.action-icon--remove').click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "#steps table" do
        expect(page).not_to have_content(translated(process_step2.title))
      end
    end
  end

  context "activating a step" do
    it "activates a step" do
      within find("tr", text: translated(process_step.title)) do
        page.find('.action-icon--activate').click
      end

      within find("tr", text: translated(process_step.title)) do
        expect(page).to have_no_content("Activate")
      end
    end
  end
end
