# frozen_string_literal: true

require "spec_helper"

describe "Admin manages particpatory texts", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  before do
    component.update!(
      settings: { participatory_texts_enabled: true }
    )
  end

  def remove_previous_proposals
    Decidim::Proposals::Proposal.where(component: current_component).destroy_all
  end

  def import_document
    visit_component_admin

    find("#js-other-actions-wrapper a#participatory_texts").click
    expect(page).to have_content "PREVIEW PARTICIPATORY TEXT"
    find("a#import-doc").click
    expect(page).to have_content "ADD DOCUMENT"

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
    expect(page).to have_content "Congratulations, the following sections have been parsed from the imported document, they have been converted to proposals. Now you can review and adjust whatever you need before publishing."
    expect(page).to have_content "PREVIEW PARTICIPATORY TEXT"
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
      "3", "4",
      "Creation accountability",
      "5",
      "What should be accounted",
      "6",
      "Following up accounted results",
      "7", "8", "9", "10", "11",
      "Summary",
      "12"
    ]
    expect(proposals.count).to eq(titles.size)
    expect(proposals.published.count).to eq(titles.size)
    expect(proposals.published.order(:position).pluck(:title)).to eq(titles)
  end

  describe "importing partipatory texts from a document" do
    it "creates proposals" do
      remove_previous_proposals
      import_document
      validate_occurrences(sections: 2, subsections: 5, articles: 12)
      move_some_sections
      publish_participatory_text
      validate_published
    end
  end

  describe "accessing participatory texts in draft mode" do
    it "renders only draft proposals"
  end
end
