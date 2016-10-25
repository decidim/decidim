# frozen_string_literal: true
require "spec_helper"

describe "Participatory Processes", type: :feature do
  let(:organization) { create(:organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some processes" do
    let!(:promoted_process) { create(:participatory_process, :promoted, organization: organization) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization: organization) }

    before do
      visit decidim.participatory_processes_path
    end

    it "lists all the highlighted processes" do
      within "#highlighted-processes" do
        expect(page).to have_content("Highlighted processes")
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists all the processes" do
      within "#processes-grid" do
        expect(page).to have_content("2 processes")
        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).to_not have_content(translated(unpublished_process.title, locale: :en))
      end
    end

    it "links to the individial process page" do
      click_link(translated(participatory_process.title, locale: :en))

      expect(current_path).to eq decidim.participatory_process_path(participatory_process)
    end

    context "with active steps" do
      let!(:step) { create(:participatory_process_step, participatory_process: participatory_process) }
      let!(:active_step) do
        create(:participatory_process_step,
               :active,
               participatory_process: participatory_process,
               title: { en: "Active step", ca: "Fase activa", es: "Fase activa" },
              )
      end

      it "links to the active step" do
        visit decidim.participatory_processes_path

        within "#processes-grid .column:nth-child(2) .card__footer" do
          expect(page).to have_content("Current step: Active step")
        end
      end
    end
  end

  describe "show" do
    before do
      visit decidim.participatory_process_path(participatory_process)
    end

    it "shows the details of the given process" do
      within "main.wrapper" do
        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(participatory_process.subtitle, locale: :en))
        expect(page).to have_content(translated(participatory_process.description, locale: :en))
        expect(page).to have_content(translated(participatory_process.short_description, locale: :en))
        expect(page).to have_content(participatory_process.hashtag)
      end
    end
  end
end
