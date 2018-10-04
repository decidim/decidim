# frozen_string_literal: true

require "spec_helper"

describe "Admin manages particpatory texts", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component }
  # let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  before do
    component.update!(
      settings: { participatory_texts_enabled: true }
    )
  end

  def import_document
    visit_component_admin

    find("#js-other-actions-wrapper a#participatory_texts").click
    expect(page).to have_content "PREVIEW PARTICIPATORY TEXT"
    find("a#import-doc").click
    expect(page).to have_content "ADD DOCUMENT"

    fill_in_i18n(
      :import_participatory_texts_title,
      "#import-title",
      ca: "Algun text participatiu",
      en: "Some participatory text",
      es: "Un texto participativo"
    )
    fill_in_i18n(
      :import_participatory_texts_description,
      "#import-desc",
      ca: "La descripció d'algun text participatiu",
      en: "The description of some participatory text",
      es: "La descripción de algún texto participativo"
    )
    attach_file :import_participatory_texts_document, Decidim::Dev.asset("participatory_text.md")
    click_button "Upload document"
    expect(page).to have_content "Congratulations, the following sections have been parsed from the imported document, they have been converted to proposals. Now you can review and adjust whatever you need before publishing."
  end

  describe "importing partipatory texts from a document" do
    it "creates proposals" do
      import_document
      # validate structure
      # reorder drafts
      # publish
      # validate published
      todo
    end
  end

  describe "accessing participatory texts in draft mode" do
    it "renders all proposals, published and unpublished" do
      todo
    end
  end
end
