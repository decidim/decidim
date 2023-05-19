# frozen_string_literal: true

require "spec_helper"

describe "Participatory Processes", type: :system do
  let(:organization) { create(:organization) }
  let(:hashtag) { true }
  let(:base_description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:base_process) do
    create(
      :participatory_process,
      :active,
      organization:,
      description: base_description,
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    skip "REDESIGN_PENDING - Adapt these examples to metadata and main data content blocks and remove this file"

    switch_to_host(organization.host)
  end

  context "when the process does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_participatory_processes.description_participatory_process_path(99_999_999) }
    end
  end

  context "when going to the participatory process page" do
    let!(:participatory_process) { base_process }

    context "when requesting the participatory process description path" do
      before do
        visit decidim_participatory_processes.description_participatory_process_path(participatory_process)
      end

      it_behaves_like "has embedded video in description", :base_description

      it "shows the details of the given process" do
        within "[data-content]" do
          expect(page).to have_content("About this process")
          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(participatory_process.description, locale: :en))
          expect(page).to have_content(translated(participatory_process.meta_scope, locale: :en))
          expect(page).to have_content(translated(participatory_process.developer_group, locale: :en))
          expect(page).to have_content(translated(participatory_process.local_area, locale: :en))
          expect(page).to have_content(translated(participatory_process.target, locale: :en))
          expect(page).to have_content(translated(participatory_process.participatory_scope, locale: :en))
          expect(page).to have_content(translated(participatory_process.participatory_structure, locale: :en))
          expect(page).to have_content(I18n.l(participatory_process.start_date, format: :decidim_short_dashed))
          expect(page).to have_content(I18n.l(participatory_process.end_date, format: :decidim_short_dashed))
        end
      end
    end
  end
end
