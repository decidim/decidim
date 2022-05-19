# frozen_string_literal: true

require "spec_helper"

describe "Index Proposal Notes", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component: component) }
  let(:participatory_space) { component.participatory_space }

  let(:body) { "New awesome body" }
  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal: proposal
    )
  end

  include_context "when managing a component as an admin"

  before do
    within find("tr", text: translated(proposal.title)) do
      click_link "Answer proposal"
    end
  end

  it "shows proposal notes for the current proposal" do
    proposal_notes.each do |proposal_note|
      expect(page).to have_content(proposal_note.author.name)
      expect(page).to have_content(proposal_note.body)
    end
    expect(page).to have_selector("form")
  end

  context "when the form has a text inside body" do
    it "creates a proposal note", :slow do
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

  context "when the form hasn't text inside body" do
    let(:body) { nil }

    it "don't create a proposal note", :slow do
      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_content("There's an error in this field.")
    end
  end
end
