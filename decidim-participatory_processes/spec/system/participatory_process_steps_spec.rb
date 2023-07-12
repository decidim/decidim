# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Steps", type: :system do
  let(:organization) { create(:organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      :with_content_blocks,
      organization:,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    skip "REDESIGN_PENDING - Deprecated: Those tests, associated views, controllers and paths should be removed after fully enabling redesign. Equivalent test should be added to the content block which implements this feature"

    switch_to_host(organization.host)
  end

  context "when there are some processes with steps" do
    let!(:steps) do
      create_list(:participatory_process_step, 3, participatory_process:)
    end

    before do
      participatory_process.steps.first.update!(active: true)
    end

    it_behaves_like "accessible page" do
      before do
        visit decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process)
      end
    end

    it "lists all the steps" do
      visit decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process)

      expect(page).to have_css(".timeline__item", count: 3)
      steps.each do |step|
        expect(page).to have_content(/#{translated(step.title)}/i)
      end
    end

    it "does not show a CTA button in the process hero content block" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process)

      within "[data-process-hero]" do
        expect(page).not_to have_css("[data-cta]")
      end
    end

    context "when the active step has CTA text and url set" do
      before do
        participatory_process.steps.first.update!(cta_path: "my_path", cta_text: { en: "Take action!" })
      end

      it "shows a CTA button in the process hero content block" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        within "[data-process-hero]" do
          expect(page).to have_link("Take action!")
        end
      end
    end
  end
end
