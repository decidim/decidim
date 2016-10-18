# frozen_string_literal: true

require "spec_helper"

describe "Manage participatory process steps", type: :feature do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end
  let!(:process_step) do
    create(
      :participatory_process_step,
      participatory_process: participatory_process,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.participatory_process_path(participatory_process)
  end

  it "displays all fields from a single participatory process" do
    within "table" do
      click_link process_step.title["en"]
    end

    within "dl" do
      expect(page).to have_content(process_step.title["en"])
      expect(page).to have_content(process_step.title["es"])
      expect(page).to have_content(process_step.title["ca"])
      expect(page).to have_content(process_step.short_description["en"])
      expect(page).to have_content(process_step.short_description["es"])
      expect(page).to have_content(process_step.short_description["ca"])
      expect(page).to have_content(process_step.description["en"])
      expect(page).to have_content(process_step.description["es"])
      expect(page).to have_content(process_step.description["ca"])
    end
  end

  it "creates a new participatory_process" do
    find("#steps .actions .new").click

    within ".new_participatory_process_step" do
      fill_in :participatory_process_step_title_en, with: "My participatory process step"
      fill_in :participatory_process_step_title_es, with: "Mi fase de proceso participativo"
      fill_in :participatory_process_step_title_ca, with: "La meva fase de procés participatiu"
      fill_in :participatory_process_step_short_description_en, with: "Short description"
      fill_in :participatory_process_step_short_description_es, with: "Descripción corta"
      fill_in :participatory_process_step_short_description_ca, with: "Descripció curta"
      fill_in :participatory_process_step_description_en, with: "A longer description"
      fill_in :participatory_process_step_description_es, with: "Descripción más larga"
      fill_in :participatory_process_step_description_ca, with: "Descripció més llarga"
      fill_in :participatory_process_step_start_date, with: 1.months.ago
      fill_in :participatory_process_step_end_date, with: 2.months.from_now

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My participatory process step")
    end
  end

  it "updates a participatory_process_step" do
    within "#steps" do
      within find("tr", text: process_step.title["en"]) do
        click_link "Edit"
      end
    end

    within ".edit_participatory_process_step" do
      fill_in :participatory_process_step_title_en, with: "My new title"
      fill_in :participatory_process_step_title_es, with: "Mi nuevo título"
      fill_in :participatory_process_step_title_ca, with: "El meu nou títol"

      find("*[type=submit]").click
    end

    within ".flash" do
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
      visit decidim_admin.participatory_process_path(participatory_process)
    end

    it "deletes a participatory_process_step" do
      within find("tr", text: process_step2.title["en"]) do
        click_link "Destroy"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(process_step2.title)
      end
    end
  end
end
