# frozen_string_literal: true

require "spec_helper"

describe "Admin filters proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  context "when filtering by type" do
    let!(:emendation) { create :proposal, component: current_component }
    let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }

    before do
      within ".filters__section" do
        find("li", text: "FILTER").hover
        find("li[aria-label=Type]").hover
        within("li[aria-label=Type") do
          find("a", text: "Proposals").click
        end
      end
    end

    it "only returns proposals" do
      expect(page).to have_content(proposal.title)
      expect(page).not_to have_content(emendation.title)
    end
  end

  context "when searching" do
    before do
      visit_component_admin
    end

    context "when searching by id" do
      before do
        within ".filters__section" do
          fill_in :q_id_or_title_cont, with: proposal.id
          find("*[type=submit]").click
        end
      end

      it "returns the proposal with the given ID" do
        expect(page).to have_content(proposal.title)
      end
    end

    context "when searching by title" do
      before do
        within ".filters__section" do
          fill_in :q_id_or_title_cont, with: proposal.title
          find("*[type=submit]").click
        end
      end

      it "returns the proposal with the given ID" do
        expect(page).to have_selector(".table-list tbody", text: proposal.title)
      end
    end
  end
end
