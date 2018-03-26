# frozen_string_literal: true

require "spec_helper"

describe "Results in process group home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }

  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      participatory_processes: [participatory_process],
      organization: organization,
      name: { en: "Name", ca: "Nom", es: "Nombre" }
    )
  end

  context "when there are no results" do
    it "does not show the highlighted results section" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      expect(page).not_to have_css(".highlighted_results")
    end
  end

  context "when there are results" do
    let!(:results) do
      create_list(:result, results_count, component: component)
    end

    it "shows the highlighted results section" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)

      within ".highlighted_results" do
        expect(page).to have_css(".card--list__item", count: 4)

        results_titles = results.map { |r| translated(r.title) }
        highlighted_results = page.all(".card--list__item .card--list__heading").map(&:text)
        expect(results_titles).to include(*highlighted_results)
      end
    end
  end
end
