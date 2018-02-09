# frozen_string_literal: true

require "spec_helper"

describe "Index Proposal Notes", type: :system do
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }

  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, feature: feature) }
  let(:participatory_space) { feature.participatory_space }

  let(:body) { "New awesome body" }
  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal: proposal
    )
  end

  include_context "when managing a feature as an admin"

  before do
    visit current_path + "proposals/#{proposal.id}/proposal_notes"
  end

  it "shows all proposal notes for the given proposal" do
    proposal_notes.each do |proposal_note|
      expect(page).to have_content(proposal_note.author.name)
      expect(page).to have_content(proposal_note.body)
    end
    expect(page).to have_selector("form")
  end

  context "when the form is valid" do
    it "creates a new proposal note ", :slow do
      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".comment-thread .card:last-child" do
        expect(page).to have_content("New awesome body")
      end
    end
  end

  context "when the form is not valid" do
    let(:body) { nil }

    it "not creates a new proposal note", :slow do
      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_content("There's an error in this field.")
    end
  end
end
