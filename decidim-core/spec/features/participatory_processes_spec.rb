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

    before do
      visit decidim.participatory_processes_path
    end

    it "lists all the highlighted processes" do
      within "#highlighted-processes" do
        expect(page).to have_content("Highlighted processes")
        expect(page).to have_content(promoted_process.title["en"])
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists all the processes" do
      within "#processes-grid" do
        expect(page).to have_content("2 processes")
        expect(page).to have_content(participatory_process.title["en"])
        expect(page).to have_content(promoted_process.title["en"])
        expect(page).to have_selector("article.card", count: 2)
      end
    end

    it "links to the individial process page" do
      click_link(participatory_process.title["en"])

      expect(current_path).to eq decidim.participatory_process_path(participatory_process)
    end
  end

  describe "show" do
    before do
      visit decidim.participatory_process_path(participatory_process)
    end

    it "shows the details of the given process" do
      within "main.wrapper" do
        expect(page).to have_content(participatory_process.title["en"])
        expect(page).to have_content(participatory_process.subtitle["en"])
        expect(page).to have_content(participatory_process.description["en"])
        expect(page).to have_content(participatory_process.short_description["en"])
        expect(page).to have_content(participatory_process.hashtag)
      end
    end
  end
end
