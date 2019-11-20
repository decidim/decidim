# frozen_string_literal: true

require "spec_helper"

shared_context "with admin filters" do
  # @param label: The aria-label in the LI tags to be hovered of the filter.
  # @param text_to_click: The text to click in the opened submenu of the filter.
  def visit_filtered_results(label, text_to_click)
    within ".filters__section" do
      find("li", text: "FILTER").hover
      find("li[aria-label=#{label}]").hover
      within("li[aria-label=#{label}") do
        find("a", text: text_to_click).click
      end
    end
  end

  def visit_filtered_results_by_search(text)
    within ".filters__section" do
      fill_in :q_id_or_title_cont, with: text
      find("*[type=submit]").click
    end
  end
end

describe "Admin filters proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component }
  let(:organization) { proposal.organization }
  let!(:other_proposals) { create_list(:proposal, 3, component: current_component) }

  include_context "when managing a component as an admin"
  include_context "with admin filters"

  context "when filtering by proposal type" do
    let!(:emendation) { create :proposal, component: current_component }
    let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }

    before do
      visit_filtered_results("Type", "Proposals")
    end

    it "only returns proposals" do
      expect(page).to have_content(proposal.title)
      expect(page).not_to have_content(emendation.title)
    end
  end

  context "when filtering by status 'accepted'" do
    let!(:accepted_proposal) { create :proposal, :accepted, component: current_component }

    before do
      visit_filtered_results("Status", "Accepted")
    end

    it "only returns accepted proposals" do
      expect(page).to have_content(accepted_proposal.title)
      (other_proposals + [proposal]).each do |prop|
        expect(page).not_to have_content(prop.title)
      end
    end
  end

  context "when filtering by scope" do
    let!(:scope) { create(:scope, organization: organization) }

    before do
      proposal.update(scope: scope)
      visit_filtered_results("Scope", translated(scope.name))
    end

    it "only returns accepted proposals" do
      expect(page).to have_content(proposal.title)
      other_proposals.each do |prop|
        expect(page).not_to have_content(prop.title)
      end
    end
  end

  context "when searching" do
    before do
      visit_component_admin
    end

    context "when searching by id" do
      before do
        visit_filtered_results_by_search(proposal.id)
      end

      it "returns the proposal with the given ID" do
        expect(page).to have_content(proposal.title)
      end
    end

    context "when searching by title" do
      before do
        visit_filtered_results_by_search(proposal.title)
      end

      it "returns the proposal with the given ID" do
        expect(page).to have_selector(".table-list tbody", text: proposal.title)
      end
    end
  end
end
