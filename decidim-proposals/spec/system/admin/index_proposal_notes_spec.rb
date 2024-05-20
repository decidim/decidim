# frozen_string_literal: true

require "spec_helper"

describe "Index Proposal Notes" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component:) }
  let(:participatory_space) { component.participatory_space }
  let(:attributes) { attributes_for(:proposal_note) }

  let(:body) { "New awesome body" }
  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal:
    )
  end

  include_context "when managing a component as an admin"

  before do
    within "tr", text: translated(proposal.title) do
      click_on "Answer proposal"
    end
    click_on "Private notes"
  end

  it "shows proposal notes for the current proposal" do
    proposal_notes.each do |proposal_note|
      expect(page).to have_content(proposal_note.author.name)
      expect(page).to have_content(decidim_sanitize_translated(proposal_note.body))
    end
    expect(page).to have_css("form")
  end

  context "when the form has a text inside body" do
    it "creates a proposal note", versioning: true do
      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: attributes[:body]

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      click_on "Private notes"
      within ".component__show_notes-grid .comment:last-child" do
        expect(page).to have_content(decidim_sanitize_translated(attributes[:body]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("left a private note on the #{translated(proposal.title)} proposal")
    end
  end

  context "when the form has not text inside body" do
    let(:body) { nil }

    it "do not create a proposal note", :slow do
      within ".new_proposal_note" do
        fill_in :proposal_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_content("There is an error in this field.")
    end
  end
end
