# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage proposals" do
  context "previewing proposals" do
    it "allows the user to preview the proposal" do
      new_window = window_opened_by { click_link proposal.title }

      within_window new_window do
        expect(current_path).to eq decidim_proposals.proposal_path(id: proposal.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(proposal.title))
      end
    end
  end

  it "creates a new proposal" do
    find(".actions .new").click

    within ".new_proposal" do
      fill_in :proposal_title, with: "Make decidim great again"
      fill_in :proposal_body, with: "Decidim is great but it can be better"
      select category.name["en"], from: :proposal_category_id
      select scope.name, from: :proposal_scope_id

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      proposal = Decidim::Proposals::Proposal.last

      expect(page).to have_content("Make decidim great again")
      expect(proposal.body).to eq("Decidim is great but it can be better")
      expect(proposal.category).to eq(category)
      expect(proposal.scope).to eq(scope)
    end
  end
end
