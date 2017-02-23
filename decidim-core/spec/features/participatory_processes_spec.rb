# coding: utf-8
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
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists all the processes" do
      within "#processes-grid" do
        within "#processes-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).not_to have_content(translated(unpublished_process.title, locale: :en))
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

        within find("#processes-grid .column", text: translated(participatory_process.title)) do
          within ".card__footer" do
            expect(page).to have_content("Current step: Active step")
          end
        end
      end
    end
  end

  describe "show" do
    let!(:published_feature) { create(:feature, :published, participatory_process: participatory_process) }
    let!(:unpublished_feature) { create(:feature, :unpublished, participatory_process: participatory_process) }

    before do
      visit decidim.participatory_process_path(participatory_process)
    end

    it "shows the details of the given process" do
      within "div.wrapper" do
        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(participatory_process.subtitle, locale: :en))
        expect(page).to have_content(translated(participatory_process.description, locale: :en))
        expect(page).to have_content(translated(participatory_process.short_description, locale: :en))
        expect(page).to have_content(translated(participatory_process.meta_scope, locale: :en))
        expect(page).to have_content(translated(participatory_process.developer_group, locale: :en))
        expect(page).to have_content(translated(participatory_process.local_area, locale: :en))
        expect(page).to have_content(translated(participatory_process.target, locale: :en))
        expect(page).to have_content(translated(participatory_process.participatory_scope, locale: :en))
        expect(page).to have_content(translated(participatory_process.participatory_structure, locale: :en))
        expect(page).to have_content(I18n.l(participatory_process.end_date, format: :long))
        expect(page).to have_content(participatory_process.hashtag)
      end
    end

    let(:attached_to) { participatory_process }
    it_behaves_like "has attachments"

    context "when the process has some features" do
      it "shows the features" do
        within ".process-nav" do
          expect(page).to have_content(translated(published_feature.name, locale: :en).upcase)
          expect(page).to have_no_content(translated(unpublished_feature.name, locale: :en).upcase)
        end
      end
    end
  end
end
