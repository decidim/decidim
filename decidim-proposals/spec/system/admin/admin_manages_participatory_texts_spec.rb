# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory texts", type: :system do
  let(:manifest_name) { "proposals" }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  before do
    component.update!(
      settings: { participatory_texts_enabled: true }
    )
  end

  def visit_participatory_texts
    visit_component_admin
    find("#js-other-actions-wrapper a#participatory_texts").click
    expect(page).to have_content "Preview participatory text"
  end

  def import_document
    find("a#import-doc").click
    expect(page).to have_content "Add document"

    fill_in_i18n(
      :import_participatory_text_title,
      "#import-title",
      ca: "Algun text participatiu",
      en: "Some participatory text",
      es: "Un texto participativo"
    )
    fill_in_i18n(
      :import_participatory_text_description,
      "#import-desc",
      ca: "La descripció d'algun text participatiu",
      en: "The description of some participatory text",
      es: "La descripción de algún texto participativo"
    )
    attach_file :import_participatory_text_document, Decidim::Dev.asset("participatory_text.md")
    click_button "Upload document"
    expect(page).to have_content "The following sections have been converted to proposals. Now you can review and adjust them before publishing."
    expect(page).to have_content "Preview participatory text"
    validate_proposals
  end

  def validate_occurrences(sections: nil, subsections: nil, articles: nil)
    expect(page).to have_content "Section:", count: sections if sections
    expect(page).to have_content "Subsection:", count: subsections if subsections
    expect(page).to have_content "Article", count: articles if articles
  end

  def move_some_sections; end

  def publish_participatory_text
    find("button[name=commit]").click
    expect(page).to have_content "All proposals have been published"
  end

  def validate_published
    proposals = Decidim::Proposals::Proposal.where(component: current_component)
    titles = [
      "The great title for a new law",
      "A co-creation process to create creative creations",
      "1", "2",
      "Creative consensus for the Creation",
      "3", "4", "5",
      "Creation accountability",
      "6",
      "What should be accounted",
      "7", "8",
      "Following up accounted results",
      "9", "10", "11", "12", "13",
      "Summary",
      "14", "15"
    ]
    expect(proposals.count).to eq(titles.size)
    expect(proposals.published.count).to eq(titles.size)
    expect(proposals.published.order(:position).pluck(:title).map(&:values).map(&:first)).to eq(titles)
  end

  def validate_proposals
    proposals = Decidim::Proposals::Proposal.where(component: current_component)
    proposals.each do |proposal|
      expect(proposal.title).to be_kind_of(Hash)
      expect(proposal.body).to be_kind_of(Hash)
    end
  end

  def edit_participatory_text_body(index, new_body)
    fill_in(
      "preview_participatory_text_proposals_attributes_#{index}_body",
      with: new_body
    )
  end

  def save_participatory_text_drafts
    click_button "Save draft"
    expect(page).to have_content "Participatory text successfully updated."
    expect(page).to have_content "Preview participatory text"
  end

  def discard_participatory_text_drafts
    accept_confirm "Are you sure to discard the whole participatory text draft?" do
      click_link "Discard all"
    end
    expect(page).to have_content "All participatory text drafts have been discarded."
    expect(page).to have_content "Preview participatory text"
  end

  describe "importing participatory texts from a document" do
    it "creates proposals" do
      visit_participatory_texts
      import_document
      validate_occurrences(sections: 2, subsections: 5, articles: 15)
      move_some_sections
      publish_participatory_text
      validate_published
    end
  end

  describe "accessing participatory texts in draft mode" do
    let!(:proposal) { create :proposal, :draft, component: current_component, participatory_text_level: "section" }

    it "renders only draft proposals" do
      visit_participatory_texts
      validate_occurrences(sections: 1, subsections: 0, articles: 0)
    end
  end

  describe "discarding participatory texts in draft mode" do
    let!(:proposals) { create_list(:proposal, 5, :draft, component: current_component, participatory_text_level: "article") }

    it "removes all proposals in draft mode" do
      visit_participatory_texts
      validate_occurrences(sections: 0, subsections: 0, articles: 5)
      discard_participatory_text_drafts
      validate_occurrences(sections: 0, subsections: 0, articles: 0)
    end
  end

  describe "updating participatory texts in draft mode" do
    let!(:proposal) { create :proposal, :draft, component: current_component, participatory_text_level: "article" }
    let!(:new_body) { Faker::Lorem.unique.sentences(number: 3).join("\n") }

    it "persists changes and all proposals remain as drafts" do
      visit_participatory_texts
      validate_occurrences(sections: 0, subsections: 0, articles: 1)
      edit_participatory_text_body(0, new_body)
      save_participatory_text_drafts
      validate_occurrences(sections: 0, subsections: 0, articles: 1)
      proposal.reload
      expect(translated(proposal.body).delete("\r")).to eq(new_body)
    end
  end

  describe "updating participatory texts in draft mode" do
    let!(:proposal) { create :proposal, :draft, component: current_component, participatory_text_level: "article" }
    let!(:new_body) { Faker::Lorem.unique.sentences(number: 3).join("\n") }

    it "persists changes and all proposals remain as drafts" do
      visit_participatory_texts
      validate_occurrences(sections: 0, subsections: 0, articles: 1)
      edit_participatory_text_body(0, new_body)
      save_participatory_text_drafts
      validate_occurrences(sections: 0, subsections: 0, articles: 1)
      proposal.reload
      expect(translated(proposal.body).delete("\r")).to eq(new_body)
    end
  end
end
